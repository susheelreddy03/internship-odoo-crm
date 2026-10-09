#!/bin/bash
# Render sets PORT to the HTTP port it routes to, but the stock odoo entrypoint reads
# PORT as the *database* port. So this replaces it and passes the DB settings explicitly.
set -euo pipefail

DB_ARGS=(
  --db_host="$DB_HOST" --db_port="$DB_PORT"
  --db_user="$DB_USER" --db_password="$DB_PASSWORD"
  --database="$DB_NAME" --db-filter="^${DB_NAME}\$"
)

# First deploy (or when asked): install/upgrade the internship modules, then start serving.
MODULES=internship_base,internship_placement,internship_agreement,internship_monitoring,internship_completion,internship_crm,internship_vapi,internship_reporting,internship_portal
if [[ "${ODOO_INIT:-0}" == "1" ]]; then
  odoo -c /etc/odoo/odoo.conf "${DB_ARGS[@]}" -i "$MODULES" --load-language=en_GB --without-demo=all --stop-after-init
elif [[ "${ODOO_UPGRADE:-0}" == "1" ]]; then
  odoo -c /etc/odoo/odoo.conf "${DB_ARGS[@]}" -u "$MODULES" --stop-after-init
fi

exec odoo -c /etc/odoo/odoo.conf "${DB_ARGS[@]}" --http-port="${PORT:-8069}" \
  --admin_passwd="$ODOO_MASTER_PASSWORD"
