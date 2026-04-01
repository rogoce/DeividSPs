-- Estatus de Aviso de Cancelacion
-- Creado  : 05/05/2011 - Autor: Henry Giron
-- "CANCELADA POR FALTA DE PAGO" 
-- execute procedure sp_che127b('')

drop procedure sp_che127b;
create procedure sp_che127b(a_poliza char(20))
returning smallint,
		  char(255);

define _existe_rehab	smallint;
define _existe_canc		smallint;
define _con_aviso		smallint;
define _aviso			char(255);
define _cod_contratante	char(10);
define _estatus_poliza	char(1);

SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "sp_che127.trc";
--trace on;

LET _con_aviso = 0;
LET _estatus_poliza = "";
LET _aviso = "CESE";
--return 1,_aviso;
--return 0,"";  -- Inactivo por el momento. Henry

if a_poliza = "*" then
	return 0,"";
end if

let a_poliza = trim(a_poliza);

select count(*)
  into _con_aviso
  from avisocanc
 where estatus in ("Z")	  -- Z= cese
   and lower(motivo) like ('%sobat%') 
   and no_documento = a_poliza;

if _con_aviso is null then
	let _con_aviso = 0;
end if

if _con_aviso > 0 then	-- Esta por Imprimir
	foreach
		select distinct estatus_poliza
		  into _estatus_poliza
		  from	avisocanc
		 where no_documento = a_poliza
		 order by 1 asc
		 exit foreach;
	end foreach

	if _estatus_poliza = "1" then
		let _aviso = "CESE";
	else
		let _aviso = "CESE";
	end if

	return 1,_aviso;
end if

LET _con_aviso = 0;

select count(*)
  into _con_aviso
  from avisocanc
 where estatus in ("Z")
   and no_documento = a_poliza;

if _con_aviso is null then
	let _con_aviso = 0;
end if

if _con_aviso > 0 then	-- Esta por Imprimir
	select count(*)
	  into _existe_canc
	  from endedmae
	 where no_poliza = a_poliza
	   and cod_endomov = "002";

	select count(*)
	  into _existe_rehab
	  from endedmae
	 where no_poliza = a_poliza
	   and cod_endomov = "003";

	if (_existe_canc - _existe_rehab) = 0 then
		return 0,'';
	end if

	return 1,_aviso;
else
	return 0,"";
end if

end procedure;