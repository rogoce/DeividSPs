--Procedimiento para verificar el limite en los contratos de reaseguro y asi saber si tiene que ir a aprobacion en WF
--Armando Moreno M.  08/09/2017

drop procedure sp_sis453;
create procedure sp_sis453(a_no_poliza char(10), a_no_endoso char(10))
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

let _suma_asegurada = 0.00;
let _limite_max     = 0.00;
let _verif_lim      = 0;
let _n_contrato     = '';

foreach
	select sum(suma_asegurada),
		   cod_cober_reas,
		   no_unidad,
		   cod_contrato
	  into _suma_asegurada,
	       _cod_cober_reas,
		   _no_unidad,
		   _cod_contrato
	  from emifacon
	 where no_poliza = a_no_poliza
	   and no_endoso = a_no_endoso
	 group by cod_cober_reas,no_unidad,cod_contrato
	 order by no_unidad
  
    SELECT limite_maximo,
	       verificar_limite
 	  INTO _limite_max,
	       _verif_lim
	  FROM reacocob
	 WHERE cod_contrato   = _cod_contrato
   	   AND cod_cober_reas = _cod_cober_reas;
	let _suma_aseg_uni = 0.00;   
    if a_no_endoso <> '00000' then  --Es un endoso, hay que verificar cuanta suma ya tiene la unidad.
		foreach
			select sum(e.suma_asegurada),
				   e.cod_cober_reas
			  into _suma_aseg_uni,
				   _cod_cober_reas
			  from emifacon e, endedmae r
			 where e.no_poliza = r.no_poliza
			   and e.no_endoso = r.no_endoso
			   and r.actualizado = 1
			   and e.no_poliza = a_no_poliza
			   and e.no_unidad = _no_unidad
			   and e.cod_cober_reas = _cod_cober_reas
			   and e.cod_contrato   = _cod_contrato
			 group by e.cod_cober_reas, e.cod_contrato
			let _suma_asegurada = _suma_asegurada + _suma_aseg_uni;
			exit foreach;
		end foreach	 
	end if
	if _verif_lim = 1 then
		if _suma_asegurada > _limite_max then
			let _n_contrato = trim(_n_contrato) || "Unidad: " || TRIM(_no_unidad) || ",Contrato:" || _cod_contrato||", ";
			exit foreach;
		else
			let _verif_lim = 0;
		end if
	end if
end foreach
if _verif_lim = 1 then
	let _mensaje = 'Suma Asegurada Excede limite de Contrato: ' || _n_contrato || " Ira a Aprobacion en Workflow.";
	return 1,_mensaje;
end if
return 0,"";
end procedure
