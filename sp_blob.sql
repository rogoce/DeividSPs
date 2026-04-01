DROP PROCEDURE sp_blob;

CREATE PROCEDURE "informix".sp_blob()
returning integer,
		  integer,
          varchar(70);

define _error_code		integer;
define _error_isam		integer;
define _error_desc		varchar(70);

define _cantidad		integer;

set isolation to dirty read;

begin 
on exception set _error_code,_error_isam,_error_desc
	return _error_code,_error_isam ,trim(_error_desc);
end exception


	SELECT ramo_sis
	  INTO _cantidad
	  FROM prdramo
	 WHERE ramo_sis = 1;

end
END PROCEDURE; 