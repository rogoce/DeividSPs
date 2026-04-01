-- Procedure que verifica si la suma asegurada de emipomae corresponde a la sumatoria en reaseguro
--drop procedure sp_pro336a;

create procedure sp_pro336a(a_no_poliza char(10)) 
returning smallint,varchar(100);

define _mensaje			varchar(100);
define _cod_agente		char(5);
define _cod_tipoprod	char(3);
define _cod_cober_reas	char(3); 
define _cod_ramo		char(3); 
define _tipo_agente		char(1);
define _suma_asegurada	dec(16,2);
define _suma_rea		dec(16,2);
define _porc_coaseguro	dec(16,4);
define _renueva			smallint;
define _flag			smallint;

--SET DEBUG FILE TO "sp_pro336a.trc";
--TRACE ON;                                                                 

set isolation to dirty read;

let _flag = 0;
let _mensaje = "";

select suma_asegurada,
	   cod_tipoprod,
	   cod_ramo
  into _suma_asegurada,
	   _cod_tipoprod,
	   _cod_ramo
  from emipomae
 where no_poliza = a_no_poliza;

if _cod_tipoprod = '001' then --coas mayoritario

	select porc_partic_coas
	  into _porc_coaseguro
	  from emicoama
	 where no_poliza    = a_no_poliza
	   and cod_coasegur = "036";  --Ancon

	if _porc_coaseguro is null then
		let _porc_coaseguro = 0.00;		          
	end if

	let _suma_asegurada = _suma_asegurada * (_porc_coaseguro / 100);
end if

foreach
	select sum(suma_asegurada),
		   cod_cober_reas
	  into _suma_rea,
		   _cod_cober_reas
	  from emifacon
	 where no_poliza = a_no_poliza
	   and no_endoso = '00000'
	 group by cod_cober_reas


	if (_cod_ramo = '001' and _cod_cober_reas = '001') or (_cod_ramo = '003' and _cod_cober_reas = '003') then
	else
	   continue foreach;
	end if

	if _cod_tipoprod <> '001' then		 --> CASO: 12336 USER: JAQUELIN  
		if abs(_suma_asegurada - _suma_rea) > 0.03 then
			let _mensaje = 'Debe entrar al Reaseguro, Suma Asegurada Diferente, Por Favor Verifique...';
			return 1, _mensaje;
		end if
	else
		if abs(_suma_asegurada - _suma_rea) > 0.50 then
			let _mensaje = 'Debe entrar al Reaseguro, Suma Asegurada Diferente, Por Favor Verifique...';
			return 1, _mensaje;
		end if
	end if
end foreach

return _flag,_mensaje;

end procedure;