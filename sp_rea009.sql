-- Cargar la tabla de comprobantes de reaseguro

-- Creado    : 08/02/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_rea009;

create procedure "informix".sp_rea009()
returning integer,
		  char(100);

define _no_poliza	char(10);
define _no_remesa	char(10);
define _no_endoso	char(5);
define _no_tranrec	char(10);

define _ano			smallint;
define _periodo		char(7);
define _fecha		date;

define _error		integer;
define _error_desc	char(50);

set isolation to dirty read;

--call sp_sac104() returning _ano, _periodo, _fecha;

select periodo_verifica
  into _periodo
  from emirepar;
  
--{
foreach
 select no_poliza,
        no_endoso
   into _no_poliza,
        _no_endoso
   from endedmae
  where periodo     = _periodo
    and actualizado = 1

	call sp_rea008(1, _no_poliza, _no_endoso) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if 

end foreach
--}

--{
foreach
 select no_remesa
   into _no_remesa
   from cobremae
  where periodo     = _periodo
    and actualizado = 1

	call sp_rea008(2, _no_remesa) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if 

end foreach
--}

--{
foreach
 select no_tranrec
   into _no_tranrec
   from rectrmae
  where periodo     = _periodo
    and actualizado = 1

	call sp_rea008(3, _no_tranrec) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if 

end foreach
--}

-- Cheques Pagados - Devolucion de Primas

--{
--if _fecha <= "30/06/2013" then
let _fecha = "01/08/2016";
--end if
 
foreach
 select no_requis
   into _no_remesa
   from chqchmae
  where pagado           = 1
    and origen_cheque    = "6"
	and fecha_impresion >= _fecha

	call sp_rea008(4, _no_remesa) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if 

end foreach
--}

-- Cheques Anulados - Devolucion de Primas

--{
foreach
 select no_requis
   into _no_remesa
   from chqchmae
  where pagado           = 1
    and anulado          = 1
    and origen_cheque    = "6"
	and fecha_anulado   >= _fecha

	call sp_rea008(5, _no_remesa) returning _error, _error_desc;

	if _error <> 0 then
		return _error, _error_desc;
	end if 

end foreach
--}

return 0, "Actualizacion Exitosa";

end procedure