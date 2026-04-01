-- Procedure que verifica si la suma asegurada de emipomae corresponde a la sumatoria en reaseguro

--drop procedure sp_pro336b;

create procedure sp_pro336b(a_no_poliza char(10)) 
returning smallint,varchar(100);

define _cod_agente	    char(5);
define _tipo_agente		char(1);
define _flag,_renueva   smallint;
define _suma_asegurada  dec(16,2);
define _suma_rea        dec(16,2);
define _mensaje         varchar(100);
define _cod_tipoprod    char(3);
define _porc_coaseguro	dec(16,4);
define _cod_ramo        char(3); 

--SET DEBUG FILE TO "sp_pro336b.trc";
--TRACE ON;                                                                 

set isolation to dirty read;

let _flag = 0;
let _mensaje = "";

select suma_asegurada,cod_tipoprod,cod_ramo
  into _suma_asegurada,_cod_tipoprod,_cod_ramo
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

	SELECT SUM(suma_asegurada)
	  INTO _suma_rea
	  FROM emifacon
	 WHERE no_poliza = a_no_poliza
	   AND no_endoso = '00000'
	 group by cod_cober_reas

	IF _cod_tipoprod <> '001' THEN		 --> CASO: 12336 USER: JAQUELIN  
		IF abs(_suma_asegurada - _suma_rea) > 0.03 THEN
			LET _mensaje = 'Debe entrar al Reaseguro, Suma Asegurada Diferente, Por Favor Verifique...';
			RETURN 1, _mensaje;
		END IF
	Else
		IF abs(_suma_asegurada - _suma_rea) > 0.50 THEN
			LET _mensaje = 'Debe entrar al Reaseguro, Suma Asegurada Diferente, Por Favor Verifique...';
			RETURN 1, _mensaje;
		END IF
	End If

end foreach

return _flag,_mensaje;

end procedure