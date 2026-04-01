
--drop procedure sp_sis112;

create procedure "informix".sp_sis112(a_notrx integer, a_tipo char(1), a_renglon smallint)
returning integer,integer;
--) returning char(10),char(20);

define _error			integer;
define _existe			integer;
define _fecha_hoy 		date;
define _no_poliza 		char(10);
define _poliza 			char(20);

BEGIN
ON EXCEPTION SET _error
	return _error,a_notrx;
end exception

if a_tipo = "E" then
	DELETE FROM cgltrx3 WHERE trx3_notrx = a_notrx;
	DELETE FROM cgltrx2 WHERE trx2_notrx = a_notrx;
	DELETE FROM cgltrx1 WHERE trx1_notrx = a_notrx;
else
	
	DELETE FROM cgltrx3 WHERE trx3_notrx = a_notrx;
	DELETE FROM cgltrx2 WHERE trx2_notrx = a_notrx;
--	DELETE FROM cgltrx1 WHERE trx1_notrx = a_notrx;	
end if

end

return 0,a_notrx;

end procedure

