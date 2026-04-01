--Procedimiento para verificar si colocaron la información de la garantia de pago en los facultativos
--Armando Moreno M.  08/09/2017

drop procedure sp_sis453a;
create procedure sp_sis453a(a_no_poliza char(10), a_no_endoso char(10))
returning smallint, varchar(250);

define _cod_contrato,_no_unidad	char(5);
define _cod_cober_reas	char(3);
define _cantidad		smallint;

define _nomb_contrato	char(15);
define _nomb_cober		char(20);
define _tipo_contrato	smallint;
define _serie,_verif_lim			smallint;
define _suma_asegurada,_limite_max,_suma_aseg_uni  dec(16,2);
define _mensaje varchar(250);
define _n_contrato   varchar(150);
define _cod_endomov char(3);
define _cnt         integer;
define _cant_garantia smallint;
define _cod_perfac char(3);
define _fecha_primer_p date;
define _orden smallint;
define _porc_partic_prima dec(16,2);

let _suma_asegurada = 0.00;
let _limite_max     = 0.00;
let _verif_lim      = 0;
let _n_contrato     = '';
let _cod_endomov    = null;

--set debug file to "sp_sis453a.trc";	
--trace on; 

select cod_endomov
  into _cod_endomov
  from endedmae
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;
if _cod_endomov is null or _cod_endomov = '017' or _cod_endomov = '024' or _cod_endomov = '025' then --Agregué la reversión de pronto pago ya que el endoso 024 no genera cant_garantia_pago ni cod_perfac; caso 30438
	return 0,'';                                                                                     --Se agrego el 024 Amado 28/12/2021
end if   

select count(*)
  into _cnt
  from emifafac
 where no_poliza = a_no_poliza
   and no_endoso = a_no_endoso;
if _cnt is null then
	let _cnt = 0;
end if   
if _cnt > 0 then

else
	return 0,'';
end if
let _cant_garantia  = null;
let _cod_perfac     = null;
let _fecha_primer_p = null;
foreach
	select no_unidad,
       	   cant_garantia_pago,
		   cod_perfac,
		   fecha_primer_pago,
		   cod_cober_reas,
		   orden,
		   cod_contrato
	  into _no_unidad,
	       _cant_garantia,
		   _cod_perfac,
		   _fecha_primer_p,
		   _cod_cober_reas,
		   _orden,
		   _cod_contrato
      from emifafac
	 where no_poliza = a_no_poliza
       and no_endoso = a_no_endoso
	 order by no_unidad
	 
	 let _porc_partic_prima = 0.00;
	 
	select porc_partic_prima 
	  into _porc_partic_prima
	  from emifacon
	 where no_poliza = a_no_poliza
       and no_endoso = a_no_endoso
	   and no_unidad = _no_unidad
	   and cod_cober_reas = _cod_cober_reas
	   and orden = _orden
	   and cod_contrato = _cod_contrato;
	 
	if (_cant_garantia is null or _cod_perfac is null or _fecha_primer_p is null) and _porc_partic_prima <> 0.00 then
		let _mensaje = "Debe Llenar la informacion de la Garantia de pago del Facultativo, " || "Unidad: " || TRIM(_no_unidad);
		return 1, _mensaje;
	end if
end foreach
return 0,"";
end procedure
