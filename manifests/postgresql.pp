class echoes_alert::postgresql (
  $branch   = $echoes_alert::params::branch,
  $version  = $echoes_alert::params::version,
  $dbname   = $echoes_alert::params::postgresql_dbname,
  $user     = $echoes_alert::params::postgresql_user,
  $password = $echoes_alert::params::postgresql_password,
  $ipv4acls = $echoes_alert::params::postgresql_ipv4acls,
) inherits echoes_alert::params {
  validate_string($branch)
  validate_string($version)
  validate_string($dbname)
  validate_string($user)
  validate_string($password)
  validate_array($ipv4acls)

  class { 'postgresql::server':
    listen_addresses => '*',
    ipv4acls         => $ipv4acls,
    manage_firewall  => true,
  }

  postgresql::server::db { $dbname:
    user     => $user,
    password => postgresql_password($user, $password),
  }
	file { 'dir_facter':
		ensure    => 'directory',
		path      => '/etc/facter',
		owner     => 'root',
		group     => 'root',
		mode      => '0655'
	}->

	file { 'dir_facts.d':
		ensure    => 'directory',
		path      => '/etc/facter/facts.d',
		owner     => 'root',
		group     => 'root',
		mode      => '0655'
	}->

	file { 'probe_sql_script_last_num':
		ensure    => 'present',
		path      => '/etc/facter/facts.d/probe_sql_script_last_num.txt',
		source    => "puppet:///modules/echoes_alert/probe_sql_script_last_num_${::hostname}.txt"
	}

  create_resources(sql_exec, sql_archive('/etc/puppet/environments/production/modules/echoes_alert/files/postgresql/probe_sql_script', $branch))
}
