-- Estatus de Aviso de Cancelacion
-- Creado  : 05/05/2011 - Autor: Henry Giron
-- "CANCELADA POR FALTA DE PAGO" 

drop procedure sp_che127;
create procedure sp_che127(a_poliza char(20))
 returning smallint,char(255);

define _con_aviso	       smallint;
define _cod_contratante    char(10);
define _aviso              char(255);
define _estatus_poliza     char(1);

SET ISOLATION TO DIRTY READ;
--SET DEBUG FILE TO "sp_che127.trc";
--trace on;
LET _con_aviso = 0;
LET _estatus_poliza = "";
LET _aviso = "CANCELADA POR FALTA DE PAGO";
--return 1,_aviso;
--return 0,"";  -- Inactivo por el momento. Henry
if a_poliza = "*" then
	return 0,"";
end if
let a_poliza = trim(a_poliza);

 select	count(*)
   into	_con_aviso
   from	avisocanc
  where estatus in ("I","R","M","X")
    and no_documento = a_poliza;
	if _con_aviso is null then
	   let 	_con_aviso = 0;
	end if

if _con_aviso > 0 then	-- Esta por Imprimir

 select	estatus_poliza
   into	_estatus_poliza
   from	avisocanc
  where no_documento = a_poliza;

    if _estatus_poliza = "1" then
		let _aviso = "SE EMITIO AVISO POR FALTA DE PAGO";
	else
		let _aviso = "SE EMITIO CARTA DE 48 HORAS";
	end if
	return 1,_aviso;
end if

LET _con_aviso = 0;

 select	count(*)
   into	_con_aviso
   from	avisocanc
  where estatus in ("Z")
    and no_documento = a_poliza;
	if _con_aviso is null then
	   let 	_con_aviso = 0;
	end if
if _con_aviso > 0 then	-- Esta por Imprimir
	return 1,_aviso;
{else

	foreach
	 select	cod_contratante
	   into	_cod_contratante
	   from	emipomae
	  where no_documento = a_poliza
	    order by vigencia_final desc
		exit foreach;
		end foreach

	 select	count(*)
	   into	_con_aviso
	   from	avisocanc
	  where estatus in ("Z")
	    and cod_contratante = _cod_contratante;
		if _con_aviso is null then
		   let 	_con_aviso = 0;
		end if
		if _con_aviso > 0 then	-- Esta por Imprimir
			return 1,_aviso;
		else
			 select	count(*)
			   into	_con_aviso
			   from	avisocanc
			  where estatus in ("I","M","X")
			    and cod_contratante = _cod_contratante;

				if _con_aviso is null then
				   let 	_con_aviso = 0;
				end if

				if _con_aviso > 0 then	-- Esta por Imprimir
					let _aviso = "SE EMITIO AVISO POR FALTA DE PAGO";
					return 1,_aviso;
				else
					return 0,"";
				end if
		end if }
else
	return 0,"";
end if

end procedure

		