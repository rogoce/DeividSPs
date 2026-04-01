-- POLIZAS VIGENTES 
-- sacar info de tarjetas/cuentas distintas de emision para patrimoniales
--Armando Moreno M.

DROP procedure sp_roman13;
CREATE procedure sp_roman13(a_fecha date)
RETURNING char(10),CHAR(50),char(50),char(10),char(20),char(19),CHAR(19),char(17),CHAR(17);

DEFINE _no_poliza	 	CHAR(10);
DEFINE _no_documento    CHAR(20);
DEFINE _cod_contratante char(10);
DEFINE _n_contratante,_n_formapag  	CHAR(50);
DEFINE _cod_formapag    CHAR(3);
define v_filtros        varchar(255);
define _no_tarjeta,_no_tarjeta_cob    char(19);
define _no_cuenta,_no_cuenta_cob     char(17);
define _flag,_flag2 smallint;

CALL sp_pro03("001","001",a_fecha,"001,003,005,006,007,009,010,011,012,013,014,015,017,021,022;") RETURNING v_filtros;

let _no_cuenta_cob  = '';
let _no_cuenta      = '';
let _no_tarjeta     = '';
let _no_tarjeta_cob = '';
foreach
	select no_poliza,
	       no_documento,
		   cod_contratante
	  into _no_poliza,
	       _no_documento,
		   _cod_contratante
	  from temp_perfil
	 where seleccionado = 1
	   
	select no_cuenta,
	       no_tarjeta,
		   cod_formapag
	  into _no_cuenta,
	       _no_tarjeta,
		   _cod_formapag
	  from emipomae
     where no_poliza = _no_poliza;
	 
	if _cod_formapag in('003','005') then
	else
		continue foreach;
	end if
	select nombre
	  into _n_formapag
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	select nombre
	  into _n_contratante
	  from cliclien
	 where cod_cliente = _cod_contratante;
	 
	let _flag = 0;
	
	if _cod_formapag = '003' then
		foreach
			select no_tarjeta
			  into _no_tarjeta_cob
			  from cobtacre
			 where no_documento = _no_documento
			 
			if _no_tarjeta <> _no_tarjeta_cob then
				let _flag = 1;
				exit foreach;
			end if
		end foreach
	end if
	
	if _flag = 1 then
		return _cod_contratante,_n_contratante,_n_formapag,_no_poliza,_no_documento,_no_tarjeta,_no_tarjeta_cob,'','' with resume;
	end if
	
	let _flag2 = 0;
	
	if _cod_formapag = '005' then
		foreach
			select no_cuenta
			  into _no_cuenta_cob
			  from cobcutas
			 where no_documento = _no_documento
			 
			if _no_cuenta <> _no_cuenta_cob then
				let _flag2 = 1;
				exit foreach;
			end if
		end foreach
	end if

	if _flag2 = 1 then
		return _cod_contratante,_n_contratante,_n_formapag,_no_poliza,_no_documento,'','',_no_cuenta,_no_cuenta_cob with resume;
	end if
	
end foreach
drop table temp_perfil;

END PROCEDURE;
