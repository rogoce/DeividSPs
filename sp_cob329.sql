-- Procedimiento que busca si la poliza fue cancelada por falta de pago
-- Creado    : 02/05/2013 - Autor: Amado Perez
-- Modificado: 25/07/2016 - Autor: Román Gordón -- Ninguna pólizas canceladas o anulada debe aceptar pagos. Por Instruc. Enilda Fernandez

drop procedure sp_cob329;
create procedure sp_cob329(a_no_poliza char(10))
returning smallint;

define _no_documento	char(21);
define _no_poliza		char(10);
define _cod_formapag    char(3);
define _cod_tipocan		char(3);
define _saldo		    dec(16,2);
define _estatus_poliza	smallint;
define _cnt_legal		smallint;
define _cod_no_renov    char(3);

SET ISOLATION TO DIRTY READ;

let _cod_no_renov = null;

select no_documento
  into _no_documento
  from emipomae
 where no_poliza = a_no_poliza;

call sp_sis21(_no_documento) returning _no_poliza;

if _no_poliza = '1194483' then
 return 0;
end if
--call sp_cob174(_no_documento) returning _saldo;

select estatus_poliza,
       cod_formapag,
	   cod_no_renov
  into _estatus_poliza,
       _cod_formapag,
	   _cod_no_renov
  from emipomae
 where no_poliza = _no_poliza;

select count(*)
  into _cnt_legal
  from coboutlegh
 where no_documento = _no_documento;

if _cnt_legal is null then
	let _cnt_legal = 0;
end if

--if _estatus_poliza in (2) and _cnt_legal = 0 and _cod_no_renov <> '012' then -- Excluyendo canceladas por perdida total
if _estatus_poliza in (2) and _cod_no_renov = '012' then -- Excluyendo canceladas por perdida total
	return 1;
elif _estatus_poliza in (4) then
	return 3;
else
	return 0;
end if

{let _cod_tipocan = null; 

foreach
	select cod_tipocan
	  into _cod_tipocan
	  from endedmae
	 where no_poliza = _no_poliza
	   and cod_endomov = "002"
	 order by no_endoso desc

    exit foreach;
end foreach

if _cod_tipocan = "001" and _cnt_legal = 0 then --27/04/2015
	return 1;
elif _cod_tipocan = "001" and _saldo <= 0.00 then --and _cod_formapag = '087' then	--Falta de pago
	return 1;
elif _cod_tipocan = "024" then --No tomada
	return 2;
elif _cod_tipocan = "037" then --Anulada
	return 3;
else
	return 0;
end if}

end procedure;