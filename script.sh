#!/bin/bash

# --- AUTOMATIC SUDO CHECK ---
if [[ $EUID -ne 0 ]]; then
   echo "Sudo privileges required. Switching to root..."
   exec sudo bash "$0" "$@"
   exit $?
fi

echo "=========================================="
echo "    MySQL Management Toolkit (Safe Mode)"
echo "=========================================="

# 1. Ask for OS
echo "Select your Operating System:"
echo "1) Ubuntu / Debian"
echo "2) RedHat / CentOS / RHEL"
read -p "OS Option (1 or 2): " OS_CHOICE

# 2. Ask for Action
echo -e "\nWhat would you like to do?"
echo "1) Check Status (Safe)"
echo "2) Install / Update MySQL"
echo "3) Uninstall MySQL (Caution!)"
read -p "Action Option (1, 2, or 3): " USER_ACTION

# 3. Handle Check Status
if [ "$USER_ACTION" == "1" ]; then
    echo -e "\n--- STATUS CHECK ---"
    if command -v mysql &> /dev/null; then
        echo "MySQL is installed."
        echo "Version: $(mysql --version)"
        echo "Service: $(systemctl is-active mysql || systemctl is-active mysqld)"
    else
        echo "MySQL not found."
    fi
    exit 0
fi

# 4. Handle Uninstall
if [ "$USER_ACTION" == "3" ]; then
    read -p "Are you sure you want to uninstall? (y/n): " CONFIRM
    if [[ "$CONFIRM" == "y" ]]; then
        echo "Uninstalling MySQL..."
        if [ "$OS_CHOICE" == "1" ]; then
            apt-get purge -y "mysql-community-*" "mysql-client*" "mysql-server*" "mysql-common"
            apt-get autoremove -y
        else
            dnf remove -y mysql-community-server
        fi
        echo "MySQL uninstalled."
    else
        echo "Uninstall cancelled."
    fi
    exit 0
fi

# 5. Handle Install (Ask for Version)
if [ "$USER_ACTION" == "2" ]; then
    read -p "Enter MySQL version (e.g., 8.0 or 8.4): " MYSQL_VER
    
    if [ "$OS_CHOICE" == "1" ]; then
        # UBUNTU INSTALL
        OS_RELEASE=$(lsb_release -cs 2>/dev/null || echo "jammy")
        [[ "$MYSQL_VER" == "8.4" ]] && REPO_SUB="mysql-8.4-lts" || REPO_SUB="mysql-8.0"
        
        echo "Configuring Ubuntu repo for MySQL $MYSQL_VER..."
        echo "deb http://repo.mysql.com/apt/ubuntu $OS_RELEASE $REPO_SUB" > /etc/apt/sources.list.d/mysql_new.list
        apt-get update
        apt-get install -y mysql-community-server mysql-community-client mysql-client mysql-common
    else
        # REDHAT INSTALL
        EL_VER=$(rpm -E %rhel)
        echo "Configuring RedHat repo for MySQL $MYSQL_VER..."
        cat <<EOF > /etc/yum.repos.d/mysql-community.repo
[mysql-community]
name=MySQL $MYSQL_VER Community Server
baseurl=https://repo.mysql.com/yum/mysql-$MYSQL_VER-community/el/$EL_VER/x86_64/
enabled=1
gpgcheck=0
EOF
        dnf install -y mysql-community-server
    fi

    # Start Service
    systemctl daemon-reload
    systemctl enable --now mysql || systemctl enable --now mysqld
    systemctl restart mysql || systemctl restart mysqld
    
    echo -e "\n--- FINAL VERIFICATION ---"
    mysql --version
    echo "Service: $(systemctl is-active mysql || systemctl is-active mysqld)"
fi