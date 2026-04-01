
DROP PROCEDURE sp_arregla_data3;

CREATE PROCEDURE sp_arregla_data3(a_periodo char(7),a_periodo2 char(7))
--}
RETURNING CHAR(20),char(10),char(5),char(5),dec(16,2),dec(16,2),char(7);

DEFINE _mensaje         CHAR(100);
DEFINE _cod_compania	CHAR(3);
DEFINE _cod_sucursal	CHAR(3);
DEFINE _cod_endomov		CHAR(3);
DEFINE _tipo_mov		SMALLINT;
DEFINE _periodo_par     CHAR(7);
DEFINE _periodo_end     CHAR(7);
DEFINE _cod_tipocan     CHAR(3);
DEFINE _vigencia_inic   DATE;
DEFINE _vigencia_final	DATE;
DEFINE _prima_bruta     DEC(16,2);
DEFINE _impuesto        DEC(16,2);
DEFINE _prima_neta      DEC(16,2);
DEFINE _descuento       DEC(16,2);
DEFINE _recargo         DEC(16,2);
DEFINE _prima           DEC(16,2);
DEFINE _prima_suscrita  DEC(16,2);
DEFINE _prima_retenida  DEC(16,2);
DEFINE _no_fac_orig,nvo_no_pol     CHAR(10);
DEFINE _error			SMALLINT;
DEFINE _cod_tipoprod	CHAR(3);
DEFINE _tipo_produccion	SMALLINT;
DEFINE _porcentaje		DEC(16,4);
DEFINE _cod_coasegur	CHAR(3);

DEFINE _prima_sus_sum	DEC(16,2);
DEFINE _prima_sus_cal	DEC(16,2);
DEFINE _cantidad		INTEGER;
DEFINE _no_unidad		CHAR(5);
DEFINE _cobertura		CHAR(5);
DEFINE _no_endoso_ext	CHAR(5);
DEFINE _tiene_impuesto	SMALLINT;
DEFINE _no_endoso       CHAR(5);
DEFINE _user_added		CHAR(8);
DEFINE _cod_formapag    CHAR(3);
DEFINE _tipo_forma	    smallint;
define _return			smallint;

DEFINE _cod_asegurado	char(10);
DEFINE _consignado		varchar(50,0);
DEFINE _tipo_embarque	char(1);
DEFINE _clausulas		varchar(50,0);
DEFINE _contenedor		varchar(50,0);
DEFINE _sello			varchar(50,0);
DEFINE _fecha_viaje		date;
DEFINE _viaje_desde		varchar(50,0);
DEFINE _viaje_hasta		varchar(50,0);
DEFINE _no_documento    char(20);
define _no_poliza       char(10);
define _cnt				smallint;
define _prima_contrato  dec(16,2);
DEFINE _cod_contrato	 CHAR(5);
define _tipo_contrato,_existe   smallint; 

let _prima_suscrita = 0;
let _prima_retenida = 0;
let _prima_contrato = 0;
let _prima = 0;

SET ISOLATION TO DIRTY READ;

BEGIN

foreach
	select no_poliza,
	       no_endoso,
		   no_documento,
		   prima_retenida,
		   prima_suscrita
	  into _no_poliza,
	  	   _no_endoso,
		   _no_documento,
		   _prima_retenida,
		   _prima_suscrita
	  from endedmae
	 where actualizado       = 1
	   and no_documento[1,2] = '18'
	   and periodo           >= a_periodo
	   and periodo           <= a_periodo2

--	   and cod_endomov       = '014'

--	   and no_documento = "1800-00035-01"

	-- verificar con endeduni	
	let _prima_suscrita = 0;

	foreach
		select no_unidad,prima_suscrita
		  into _no_unidad,_prima_suscrita
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso

		let _prima = 0;
		select sum(prima)
		  into _prima
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad;

		if _prima is null then 
			let _prima = 0;
		end if

		if _prima <> _prima_suscrita then

				

			    RETURN _no_documento,
					   _no_poliza,
					   _no_endoso,
					   _no_unidad,
					   _prima_suscrita,
					   _prima,
					   a_periodo
				  WITH RESUME;						

				let _existe = 0;
				select count(*)
				  into _existe
				  from emifacon
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and no_unidad = _no_unidad;

				if _existe = 0 then			   
	               Insert Into emifacon(no_poliza,no_endoso,no_unidad,cod_cober_reas,orden,cod_contrato,cod_ruta,porc_partic_prima,porc_partic_suma,suma_asegurada,prima)
				   Values (_no_poliza,_no_endoso,_no_unidad,'019',1,'00588','00395',100,100,0,_prima_suscrita);
			   end if
		end if 
	end foreach				
			
end foreach

{	foreach
		select no_unidad,prima_suscrita
		  into _no_unidad,_prima_suscrita
		  from endeduni
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso

		select count(*)
		  into _cnt
		  from emifacon
		 where no_poliza = _no_poliza
		   and no_endoso = _no_endoso
		   and no_unidad = _no_unidad;

--		   and cod_cober_reas = '019';

		if _cnt = 0  then

			    RETURN _no_documento,
					   _no_poliza,
					   _no_endoso,
					   _no_unidad,
					   _prima_suscrita,
					   a_periodo
				  WITH RESUME;

             --  Insert Into emifacon(no_poliza,no_endoso,no_unidad,cod_cober_reas,orden,cod_contrato,cod_ruta,porc_partic_prima,porc_partic_suma,suma_asegurada,prima)
			 --  Values (_no_poliza,_no_endoso,_no_unidad,'019',1,'00577','00378',100,100,0,_prima_suscrita);
				
			
		end if }


END

END PROCEDURE;