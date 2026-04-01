-- Procedure que Renumera las Facturas Duplicadas

-- Creado    : 26/02/2002 - Autor: Demetrio Hurtado Almanza
-- Modificado: 26/02/2002 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_para_sp_par54_dw1 - DEIVID, S.A.

drop procedure sp_par54;

create procedure sp_par54()
returning char(10),
		  char(10);

define _no_poliza		char(10);
define _no_endoso		char(5);

define _no_tran_int		integer;
define _no_tran_char	char(10);
define _no_factura		char(10);
define _error			integer;

let _no_tran_int  = 1234;
let _no_tran_char = '99-0000000';

begin 

ON EXCEPTION SET _error 
	rollback work;
 	RETURN "", "";         
END EXCEPTION           

begin work;

foreach
 select	no_poliza,
        no_endoso,
		no_factura
   into	_no_poliza,
        _no_endoso,
		_no_factura
   from	endedmae
  where	no_factura >= "01-116605"
    and no_factura <= "01-116879"
	and actualizado = 1
	and cod_endomov = "014"
  order by no_factura

	let _no_tran_int = _no_tran_int + 1;

	IF _no_tran_int > 9999  THEN
		LET _no_tran_char[4,10] = _no_tran_int;
	ELIF _no_tran_int > 999 THEN
		LET _no_tran_char[5,10] = _no_tran_int;
	ELIF _no_tran_int > 99  THEN
		LET _no_tran_char[6,10] = _no_tran_int;
	ELIF _no_tran_int > 9   THEN
		LET _no_tran_char[7,10] = _no_tran_int;
	ELSE
		LET _no_tran_char[8,10] = _no_tran_int;
	END IF

	update endedmae
	   set no_factura = _no_tran_char
	 where no_poliza  = _no_poliza
	   and no_endoso  = _no_endoso;

	return _no_factura, 
		   _no_tran_char
		   with resume;

end foreach  

commit work;

end 

end procedure

