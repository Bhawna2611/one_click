#!/bin/bash

echo "=========================================="
echo "    MySQL Tool (Docker Optimized)"
echo "=========================================="

# 1. Ask for OS
echo "Select Operating System for setup:"
echo "1) Ubuntu / Debian (APT)"
echo "2) RedHat / CentOS / RHEL (DNF)"
read -p "OS Choice (1 or 2): " OS_CHOICE

# 2. Ask for Action
echo -e "\nWhat is your goal?"
echo "1) Check Status"
echo "2) Install / Update MySQL"
echo "3) Uninstall MySQL"
read -p "Action Choice (1, 2, or 3): " USER_ACTION

# 3. Handle Check Status
if [ "$USER_ACTION" == "1" ]; then
    if command -v mysql &> /dev/null; then
        echo "✅ MySQL is installed."
        mysql --version
    else
        echo "❌ MySQL not found in this container."
    fi
    exit 0
fi

# 4. Handle Uninstall
if [ "$USER_ACTION" == "3" ]; then
    echo "Removing MySQL packages..."
    if [ "$OS_CHOICE" == "1" ]; then
        apt-get purge -y "mysql-community-*" "mysql-client*" "mysql-server*" "mysql-common"
        apt-get autoremove -y
    else
        dnf remove -y mysql-community-server
    fi
    echo "✅ Done."
    exit 0
fi

# 5. Handle Install
if [ "$USER_ACTION" == "2" ]; then
    read -p "Enter version (8.0 or 8.4): " MYSQL_VER
    
    if [ "$OS_CHOICE" == "1" ]; then
        echo "Aggressively cleaning old MySQL metadata..."
        
        # 1. Force remove old repo lists to prevent signature conflicts
        rm -f /etc/apt/sources.list.d/mysql*
        
        # 2. Wipe the local APT cache (This kills the 'Expired Key' memory)
        rm -rf /var/lib/apt/lists/*
        
        # 3. Install basic tools (Allow insecure temporarily to get keys)
        apt-get update -o Acquire::AllowInsecureRepositories=true || true
        apt-get install -y gnupg wget lsb-release

        # 4. Delete the bad key from the old keyring
        apt-key del B7B3B788A8D3785C 2>/dev/null
        
        # 5. Setup new secure keyring for the 2023 key
        mkdir -p /etc/apt/keyrings
        wget -qO- https://repo.mysql.com/RPM-GPG-KEY-mysql-2023 | gpg --dearmor -o /etc/apt/keyrings/mysql.gpg
        
        OS_RELEASE=$(lsb_release -cs 2>/dev/null || echo "jammy")
        [[ "$MYSQL_VER" == "8.4" ]] && REPO_SUB="mysql-8.4-lts" || REPO_SUB="mysql-8.0"
        
        # 6. Create fresh repo list pointing to the new key
        echo "deb [signed-by=/etc/apt/keyrings/mysql.gpg] http://repo.mysql.com/apt/ubuntu $OS_RELEASE $REPO_SUB" > /etc/apt/sources.list.d/mysql_new.list
        
        # 7. Final sync (Now with a clean slate)
        echo "Updating repositories..."
        apt-get update
        
        echo "Installing MySQL Community Server..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-community-server
    else
        echo "Configuring RedHat repo..."
        EL_VER=$(rpm -E %rhel)
        cat <<EOF > /etc/yum.repos.d/mysql-community.repo
[mysql-community]
name=MySQL $MYSQL_VER
baseurl=https://repo.mysql.com/yum/mysql-$MYSQL_VER-community/el/$EL_VER/x86_64/
enabled=1
gpgcheck=0
EOF
        dnf install -y mysql-community-server
    fi

    # Start the service
    echo "Attempting to start MySQL service..."
    service mysql start || echo "Note: Service command sent."
    
    echo -e "\n--- FINAL VERIFICATION ---"
    mysql --version
fi