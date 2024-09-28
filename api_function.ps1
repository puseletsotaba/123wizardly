# Import the necessary modules
Import-Module Universal

# Connecting to SQLite database
$databasePath = "Users/puse/Downloads/smartapi/tasks.sqlite"
$connectionString = "Data Source=$databasePath;Version=3;"
$connection = New-Object System.Data.SQLite.SQLiteConnection($connectionString)

# Creating a RESTAPI

New-UEndpoint -Url "/tasks" -Method GET -Endpoint {
    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT * FROM tasks"
    $collector = $command.ExecuteReader()

    $tasks = @()
    while ($collector.Read()) {
        $tasks += @{
            id          = $collector["id"]
            title       = $collector["title"]
            description = $collector["description"]
            completed   = $collector["completed"]
            due_date  = $collector["due_date"]
            priority = $collector["priority"]
        }
    }
    $connection.Close()
    return $tasks
}

New-UEndpoint -Url "/tasks" -Method POST -Endpoint {
    param (
        [string]$title,
        [string]$description
    )

    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = "INSERT INTO tasks (title, description) VALUES (@title, @description)"
    $command.Parameters.Add((New-Object Data.SQLite.SQLiteParameter("@title", $title)))
    $command.Parameters.Add((New-Object Data.SQLite.SQLiteParameter("@description", $description)))
    $command.ExecuteNonQuery()
    $connection.Close()

    return @{ message = "Task created successfully." }
}

New-UEndpoint -Url "/tasks/{id}" -Method GET -Endpoint {
    param (
        [int]$id
    )

    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT * FROM tasks WHERE id = @id"
    $command.Parameters.Add((New-Object Data.SQLite.SQLiteParameter("@id", $id)))
    $collector = $command.ExecuteReader()

    if ($collector.Read()) {
        $task = @{
            id          = $collector["id"]
            title       = $collector["title"]
            description = $collector["description"]
            completed   = $collector["completed"]
            due_date  = $collector["due_date"]
            priority = $collector["priority"]
        }
    }
    else {
        return @{ message = "Task not found." }
    }
    $connection.Close()
    return $task
}

New-UEndpoint -Url "/tasks/{id}" -Method PUT -Endpoint {
    param (
        [int]$id,
        [string]$title,
        [string]$description,
        [bool]$completed,
        [string]$priorty
    )

    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = "UPDATE tasks SET title = @title, description = @description, completed = @completed WHERE id = @id"
    $command.Parameters.Add((New-Object Data.SQLite.SQLiteParameter("@title", $title)))
    $command.Parameters.Add((New-Object Data.SQLite.SQLiteParameter("@description", $description)))
    $command.Parameters.Add((New-Object Data.SQLite.SQLiteParameter("@completed", $completed)))
    $command.Parameters.Add((New-Object Data.SQLite.SQLiteParameter("@id", $id))),
    $command.Parameters.Add((New-Object Data.SQLite.SQLiteParameter("@priority", $priority)))
    $command.ExecuteNonQuery()
    $connection.Close()

    return @{ message = "Task updated successfully." }
}

New-UEndpoint -Url "/tasks/{id}" -Method DELETE -Endpoint {
    param (
        [int]$id
    )

    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = "DELETE FROM tasks WHERE id = @id"
    $command.Parameters.Add((New-Object Data.SQLite.SQLiteParameter("@id", $id)))
    $command.ExecuteNonQuery()
    $connection.Close()

    return @{ message = "Task deleted successfully." }
}

