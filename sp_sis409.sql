
drop procedure sp_sis409;

create procedure "informix".sp_sis409(a_no_requis char(10))
returning char(10),char(20),char(30),char(5);

define _no_requis		char(10);
define _no_poliza       char(10);
define _no_documento    char(20);
define _no_motor        char(30);
define _transaccion		char(10);
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _fecha           date;
define _no_unidad       char(5);

--set debug file to "sp_rec95.trc";
--trace on;
--set isolation to dirty read;

SET LOCK MODE TO WAIT;

begin

CREATE TEMP TABLE tmp_saber(
		no_documento    CHAR(20)	NOT NULL,
		no_poliza       char(10)    NOT NULL,
		no_motor        CHAR(30)	NOT NULL,
		no_unidad       CHAR(5)  	NOT NULL
		) WITH NO LOG;


{let _no_requis = null;
let _fecha     = null;

foreach
	select transaccion
	  into _transaccion
	  from chqchrec
	 where no_requis = a_no_requis

	 Update rectrmae
		Set no_requis      = _no_requis,
			pagado         = 0,
			fecha_pagado   = _fecha,
			generar_cheque = 0
	  where transaccion    = _transaccion;


end foreach}


foreach

	select no_poliza,no_documento
	  into _no_poliza,_no_documento
	  from emipomae
	 where actualizado = 1
	   and cod_ramo    = '020'
	   and periodo     >= a_no_requis
	   and periodo     <= '2013-07'
	   and estatus_poliza in(1,3)
	 order by 1,2

   foreach
	select no_motor,no_unidad
	  into _no_motor,_no_unidad
	  from emiauto
	 where no_poliza = _no_poliza

    insert into tmp_saber(no_documento,no_poliza,no_motor,no_unidad)
	values(_no_documento,_no_poliza,_no_motor,_no_unidad);

	--return _no_poliza,_no_documento,_no_motor,_no_unidad with resume;
   end foreach

end foreach

--return 0,"";

end

end procedure
