#!/bin/bash
# Script to export/import PostgreSQL database
# Usage: ./pg-data.sh export [database] [output-file]
# Usage: ./pg-data.sh import [database] [input-file]

ACTION=${1:-help}
DATABASE=${2:-app}
FILE=${3:-${DATABASE}-$(date +%Y%m%d%H%M%S).sql}
NAMESPACE="database"
CLUSTER_NAME="postgres-cluster"

# Function to get the primary pod
get_primary_pod() {
  kubectl get pods -n ${NAMESPACE} -l postgresql=${CLUSTER_NAME},role=primary -o name 2>/dev/null | cut -d'/' -f2
}

# Function to export database
export_db() {
  local pod=$1
  local db=$2
  local file=$3
  
  echo "Exporting database '${db}' to file '${file}'"
  kubectl exec -it -n ${NAMESPACE} ${pod} -- pg_dump -U postgres -d ${db} --clean --if-exists > ${file}
  
  if [ $? -eq 0 ]; then
    echo "✅ Export successful: ${file} ($(du -h ${file} | cut -f1))"
  else
    echo "❌ Export failed"
    exit 1
  fi
}

# Function to import database
import_db() {
  local pod=$1
  local db=$2
  local file=$3
  
  if [ ! -f "${file}" ]; then
    echo "❌ Input file '${file}' not found"
    exit 1
  fi
  
  echo "Importing file '${file}' into database '${db}'"
  cat ${file} | kubectl exec -i -n ${NAMESPACE} ${pod} -- psql -U postgres -d ${db}
  
  if [ $? -eq 0 ]; then
    echo "✅ Import successful"
  else
    echo "❌ Import failed"
    exit 1
  fi
}

# Function to display help
show_help() {
  echo "PostgreSQL Database Export/Import Tool"
  echo ""
  echo "Usage:"
  echo "  $0 export [database] [output-file]    Export a database to a file"
  echo "  $0 import [database] [input-file]     Import a database from a file"
  echo ""
  echo "Examples:"
  echo "  $0 export app                         Export 'app' database to app-[timestamp].sql"
  echo "  $0 export app_db mydata.sql           Export 'app_db' database to mydata.sql"
  echo "  $0 import app mydata.sql              Import mydata.sql into 'app' database"
  echo ""
}

# Main function
main() {
  # Show help if requested or no action specified
  if [ "$ACTION" = "help" ] || [ -z "$ACTION" ]; then
    show_help
    exit 0
  fi
  
  # Check action
  if [ "$ACTION" != "export" ] && [ "$ACTION" != "import" ]; then
    echo "❌ Invalid action: ${ACTION}"
    show_help
    exit 1
  fi
  
  # Get primary pod
  PRIMARY_POD=$(get_primary_pod)
  if [ -z "$PRIMARY_POD" ]; then
    echo "❌ Could not find the primary PostgreSQL pod"
    echo "Available pods in namespace ${NAMESPACE}:"
    kubectl get pods -n ${NAMESPACE}
    exit 1
  fi
  
  # Perform action
  if [ "$ACTION" = "export" ]; then
    export_db ${PRIMARY_POD} ${DATABASE} ${FILE}
  elif [ "$ACTION" = "import" ]; then
    import_db ${PRIMARY_POD} ${DATABASE} ${FILE}
  fi
}

# Run main function
main
