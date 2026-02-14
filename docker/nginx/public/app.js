// API Base URL
const API_URL = '/api/employees';

// Show alert message
function showAlert(message, type = 'success') {
    const alertContainer = document.getElementById('alert-container');
    const alert = document.createElement('div');
    alert.className = `alert alert-${type}`;
    alert.textContent = message;
    alertContainer.innerHTML = '';
    alertContainer.appendChild(alert);

    // Auto-hide after 5 seconds
    setTimeout(() => {
        alert.remove();
    }, 5000);
}

// Load all employees
async function loadEmployees() {
    const loading = document.getElementById('loading');
    const tableBody = document.getElementById('employee-table-body');
    const emptyState = document.getElementById('empty-state');

    loading.style.display = 'block';

    try {
        const response = await fetch(API_URL);
        if (!response.ok) throw new Error('Failed to fetch employees');

        const employees = await response.json();

        loading.style.display = 'none';

        if (employees.length === 0) {
            emptyState.style.display = 'block';
            tableBody.innerHTML = '';
        } else {
            emptyState.style.display = 'none';
            displayEmployees(employees);
        }
    } catch (error) {
        loading.style.display = 'none';
        showAlert('Error loading employees: ' + error.message, 'error');
    }
}

// Display employees in table
function displayEmployees(employees) {
    const tableBody = document.getElementById('employee-table-body');
    tableBody.innerHTML = '';

    employees.forEach(employee => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${employee.id}</td>
            <td>${employee.name}</td>
            <td>${employee.email}</td>
            <td>${employee.phone || '-'}</td>
            <td>${employee.department || '-'}</td>
            <td>${employee.position || '-'}</td>
            <td class="actions">
                <button class="btn btn-edit" data-id="${employee.id}">
                    ✏️ Edit
                </button>
                <button class="btn btn-danger" data-id="${employee.id}" data-name="${employee.name}">
                    🗑️ Delete
                </button>
            </td>
        `;

        // Add event listeners to the buttons
        const editBtn = row.querySelector('.btn-edit');
        editBtn.addEventListener('click', () => editEmployee(employee.id));

        const deleteBtn = row.querySelector('.btn-danger');
        deleteBtn.addEventListener('click', () => deleteEmployee(employee.id, employee.name));

        tableBody.appendChild(row);
    });
}

// Edit employee
function editEmployee(id) {
    window.location.href = `/add-employee.html?id=${id}`;
}

// Delete employee
async function deleteEmployee(id, name) {
    if (!confirm(`Are you sure you want to delete ${name}?`)) {
        return;
    }

    try {
        const response = await fetch(`${API_URL}/${id}`, {
            method: 'DELETE'
        });

        if (!response.ok) throw new Error('Failed to delete employee');

        showAlert(`${name} has been deleted successfully`, 'success');
        loadEmployees(); // Reload the list
    } catch (error) {
        showAlert('Error deleting employee: ' + error.message, 'error');
    }
}

// Load employee data for editing
async function loadEmployeeData(id) {
    try {
        const response = await fetch(`${API_URL}/${id}`);
        if (!response.ok) throw new Error('Employee not found');

        const employee = await response.json();

        // Populate form fields
        document.getElementById('name').value = employee.name;
        document.getElementById('email').value = employee.email;
        document.getElementById('phone').value = employee.phone || '';
        document.getElementById('department').value = employee.department || '';
        document.getElementById('position').value = employee.position || '';
    } catch (error) {
        showAlert('Error loading employee data: ' + error.message, 'error');
        setTimeout(() => {
            window.location.href = '/index.html';
        }, 2000);
    }
}

// Handle form submission
async function handleFormSubmit(e) {
    e.preventDefault();

    const urlParams = new URLSearchParams(window.location.search);
    const employeeId = urlParams.get('id');

    const formData = {
        name: document.getElementById('name').value,
        email: document.getElementById('email').value,
        phone: document.getElementById('phone').value,
        department: document.getElementById('department').value,
        position: document.getElementById('position').value
    };

    try {
        const url = employeeId ? `${API_URL}/${employeeId}` : API_URL;
        const method = employeeId ? 'PUT' : 'POST';

        const response = await fetch(url, {
            method: method,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(formData)
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.error || 'Failed to save employee');
        }

        const employee = await response.json();
        showAlert(
            employeeId
                ? `${employee.name} has been updated successfully!`
                : `${employee.name} has been added successfully!`,
            'success'
        );

        // Redirect to list after 1.5 seconds
        setTimeout(() => {
            window.location.href = '/index.html';
        }, 1500);
    } catch (error) {
        showAlert('Error: ' + error.message, 'error');
    }
}
