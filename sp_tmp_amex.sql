-- Procedure que borra los datos de chqpayasien y chqpaydet
-- Creado: 14/06/2012	- Autor: Roman Gordon


 													   
drop procedure sp_tmp_amex;

create procedure sp_tmp_amex()
returning char(19),
          char(20),
          char(50),
          dec(16,2);

define _nombre			char(50);
define _no_documento	char(20);
define _no_tarjeta_comp	char(19);
define _no_tarjeta		char(12);
define _no_tarjeta1		char(4);
define _no_tarjeta2		char(4);
define _monto			dec(16,2);
define _cant			integer;
define _error			integer;
DEFINE _sql_where		LVARCHAR;
define _sql_describe	LVARCHAR;

set isolation to dirty read;

set debug file to "sp_tmp_amex.trc";
trace on;

{foreach
	select no_tarjeta
	  into _no_tarjeta
	  from tmp_amex

	let _no_tarjeta1 = _no_tarjeta[1,4];
	let _no_tarjeta2 = _no_tarjeta[6,9];
	foreach
		select no_tarjeta
		  into _no_tarjeta_comp
		  from cobtacre
		 where _no_tarjeta LIKE TRIM(_no_tarjeta1) || "%" || TRIM(_no_tarjeta2) || "%"
		 
		exit foreach;
	end foreachlet _no_tarjeta_comp = ''; 
	
		
	let _no_tarjeta_comp = trim(_no_tarjeta_comp);
	foreach
		select distinct no_tarjeta,
			   no_documento,
			   nombre,
			   monto
		  into _no_tarjeta_comp,	
			   _no_documento,
			   _nombre,
			   _monto
		  from cobtacre
		 where no_tarjeta = _no_tarjeta_comp

		return _no_tarjeta_comp,
			   _no_documento,
			   _nombre,
			   _monto with resume;
	end foreach
end foreach}
foreach
	select no_tarjeta
	  into _no_tarjeta
	  from tmp_amex

	let _no_tarjeta1 = _no_tarjeta[1,4];
	let _no_tarjeta2 = _no_tarjeta[6,9];

	LET _sql_where	= " no_tarjeta like ( '" || trim(_no_tarjeta1) || "%"|| trim(_no_tarjeta2)|| "' ) and periodo = 2";
	LET _sql_describe = "SELECT no_tarjeta,no_documento,nombre,monto from cobtacre where " || _sql_where;

	PREPARE xsql FROM _sql_describe;	
	DECLARE xcur CURSOR FOR xsql;	 
	OPEN xcur;
	WHILE (1 = 1)
		FETCH xcur INTO	_no_tarjeta_comp,	
						_no_documento,
						_nombre,
						_monto; 

		IF (SQLCODE = 100) THEN
			EXIT;
		END IF

		IF (SQLCODE != 100) THEN
					  RETURN _no_tarjeta_comp,
					  		 _no_documento,
					  		 _nombre,
					  		 _monto   
					   	 WITH RESUME;
		ELSE
			EXIT;
		END IF
	END WHILE
	CLOSE xcur;	
	FREE xcur;
	FREE xsql;
end foreach
end procedure


  





































