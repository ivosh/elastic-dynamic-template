#!/bin/bash

set -e

ELASTIC_URL=https://elastic:9200
ELASTIC_USER_PASSWORD="kERSjsnwo92345kA"
ROOT_CA_CERT=certificates/sccoe_root_ca.cert
CURL_OPTIONS=("--silent" "--cacert" "${ROOT_CA_CERT}" "--ssl-no-revoke")

function get_binary_path() {
  local binary="$1"
  local default_path="$2"

  if [ -x "$default_path" ]; then
    echo "$default_path"
    return
  fi

  from_path=$( command -v "$binary" )
  if [ -x "$from_path" ]; then
    echo "$from_path"
    return
  fi

  echo "Binary $binary not found in $default_path or PATH"
  exit 1
}

CURL=$( get_binary_path "curl" "/usr/bin/curl" )

function setup_elastic_user_password() {
  printf "Setting password for elastic user... "
  ${CURL} "${CURL_OPTIONS[@]}" -X POST -H "Content-Type: application/json" \
    -u elastic:b21Qx.CPIJsTdhY \
    ${ELASTIC_URL}/_security/user/elastic/_password \
    -d "{\"password\":\"${ELASTIC_USER_PASSWORD}\"}" \
    | grep -q "^{}"
  printf "ok.\n"
}

function string_to_delimited_string() {
  local input=$1

  if [ -z "$1" ]; then
    echo ""
  elif [ "$1" = "*" ]; then
    echo '"*"'
  else
    declare -a array="(${input// / })"
    joined=$( printf ", \"%s\"" "${array[@]}" )
    echo "${joined:1}"
  fi
}

function create_role_mapping() {
  local name="$1"
  local type="$2"
  local roles_input="$3"
  local rule_fields="$4"

  roles=$(string_to_delimited_string "$roles_input")

  printf "Setting %s role mapping for role(s): %s... " "$type" "$roles_input"
  ${CURL} "${CURL_OPTIONS[@]}" -X POST -H "Content-Type: application/json" \
    -u "elastic:${ELASTIC_USER_PASSWORD}" \
    "${ELASTIC_URL}/_security/role_mapping/${name}" \
    -d "{\"enabled\": true, \"roles\": [${roles}], \"rules\": {\"all\": [${rule_fields}]}}" \
    | grep -q "^{\"role_mapping\":{\"created\":true}}"
  printf "ok.\n"
}

function create_kibana_system_role_mapping() {
  # Note: dn components are in reverse order with respect to what is displayed by 'openssl x509 -in <cert> -text'
  local rule_field="{\"field\": {\"dn\": \"c=BE,dc=SCCoE,o=RHEA,cn=sccoe-sys-elastic-kibana-client-internal\"}}"
  create_role_mapping "kibana-client-certificate" "client certificate" "kibana_system" "$rule_field"
}


setup_elastic_user_password
create_kibana_system_role_mapping
