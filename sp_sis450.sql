-- Procedimiento para validar los % de la ruta de reaseguro versus los % de la factura
-- Creado    : 25/07/2017 - Autor: Armando Moreno M.

drop procedure sp_sis450;
create procedure sp_sis450(a_no_poliza char(10),a_no_endoso	char(5))
returning smallint,char(100);

define _porc_partic_suma	dec(16,2);
define _porc_partic_prima	dec(16,2);
define _porc_partic_prima_e dec(16,2);
define _porc_partic_suma_e dec(16,2);

define _cod_cober_reas		char(3);
define _cod_endomov			char(3);
define _cod_contrato,_no_unidad,_cod_ruta 	char(5);
define _cod_ramo			char(3);

define _error				smallint;
define _error_isam			smallint;
define _error_desc			char(100);
define _vig_inic,_vig_inic_con,_vig_fin_con   date;

BEGIN

ON EXCEPTION SET _error, _error_isam, _error_desc 
 	RETURN _error, _error_desc;         
END EXCEPTION           

--set debug file to "sp_sis450.trc";
--trace on;

set isolation to dirty read;

let a_no_poliza = trim(a_no_poliza);

let _porc_partic_prima = 0.00;
let _porc_partic_suma  = 0.00;
let _porc_partic_prima_e = 0.00;
let _porc_partic_suma_e  = 0.00;

select cod_ramo
  into _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

if _cod_ramo = '019' then  --La validacion Excluye Vida individual.
	return 0,"";
end if

select cod_endomov,vigencia_inic
  into _cod_endomov,_vig_inic
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;
   

foreach
	select no_unidad,
		   porc_partic_prima,
	       porc_partic_suma,
		   cod_contrato,
		   cod_cober_reas
	  into _no_unidad,
	       _porc_partic_prima_e,
           _porc_partic_suma_e,
           _cod_contrato,
           _cod_cober_reas
	from emifacon
   where no_poliza = a_no_poliza
	 and no_endoso = a_no_endoso
	 order by no_unidad,orden

	if _porc_partic_suma_e <> _porc_partic_prima_e then
		return 1, "Los % de suma y prima deben ser iguales, Por favor Verifique... Unidad: "||_no_unidad;
	end if
	if _cod_ramo in('001','003') and _cod_endomov = '017' then
		select vigencia_inic,
		       vigencia_final
		  into _vig_inic_con,
		       _vig_fin_con
		  from reacomae
		 where cod_contrato = _cod_contrato;
		 
		if (_vig_inic >= _vig_inic_con) AND (_vig_inic <= _vig_fin_con) then	--El contrato escogido por el usuario corresponde a la vigencia del endoso
		else
		 	return 1, "El Contrato NO concuerda con la vigencia inicial del endoso, Por favor Verifique...";
		end if
	end if
	 
end foreach	 

--Exclusiones 
if _cod_ramo Not in('002','020','023') then  --Por ahora la validacion solo es para Automovil.
	return 0,"";
end if
if _cod_endomov in('017') then	--Cambio de Reaseguro
	return 0,"";
end if

let _cod_ruta = null;
foreach
	select cod_ruta
	  into _cod_ruta
	from emifacon
   where no_poliza = a_no_poliza
	 and no_endoso = a_no_endoso
	 and porc_partic_prima <> 0
	 and porc_partic_suma  <> 0
	 exit foreach;
end foreach
if _cod_ruta is null then
	return 0,"";
end if
foreach
	select no_unidad,
		   porc_partic_prima,
	       porc_partic_suma,
		   cod_contrato,
		   cod_cober_reas
	  into _no_unidad,
	       _porc_partic_prima_e,
           _porc_partic_suma_e,
           _cod_contrato,
           _cod_cober_reas
	from emifacon
   where no_poliza = a_no_poliza
	 and no_endoso = a_no_endoso
	 order by no_unidad,orden

    foreach
		 select porc_partic_suma,
			    porc_partic_prima 
		   into _porc_partic_prima,
			    _porc_partic_suma
		   from rearucon
		  where cod_ruta       = _cod_ruta
		    and cod_contrato   = _cod_contrato
		    and cod_cober_reas = _cod_cober_reas
		   
		exit foreach;
	end foreach
	if a_no_poliza = '0002969552' then   --Excepcion caso Boni 12551, poliza de ancon. AMM 20/01/2025
		return 0, "Actualizacion Exitosa";
	end if
	if _porc_partic_prima > 0 And _porc_partic_suma > 0 then
		if (_porc_partic_prima = _porc_partic_prima_e) And (_porc_partic_suma = _porc_partic_suma_e) then
		else
			return 1,"Unidad: " || _no_unidad || ", Los % en la Ruta son diferentes a los de la factura, Por favor Verifique...";
		end if
	end if

end foreach
end
return 0, "Actualizacion Exitosa";
end procedure;

