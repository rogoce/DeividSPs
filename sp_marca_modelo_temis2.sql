--  marca / modelo, DRN 12107
--
DROP procedure sp_marca_modelo_temis2;
CREATE procedure sp_marca_modelo_temis2(a_fecha date)
RETURNING char(20)     as poliza,
          char(10)     as estatus_poliza,
		  date         as vig_ini,
		  date         as vig_fin,
		  char(10)     as cod_contratante,
		  varchar(100) as n_contratante,
		  char(5)      as cod_corredor,
		  char(50)     as n_corredor,
		  char(2)      as tiene_coaseguro,
		  char(5)      as no_unidad,
		  char(5)      as cod_marca,
		  char(50)     as n_marca,
		  char(5)      as cod_modelo,
		  char(50)     as n_modelo,
		  char(50)     as tipo_auto,
          char(1)      as uso_auto,
		  smallint     as anio_auto,
		  char(30)     as no_motor,
		  char(10)     as placa,
		  char(50)     as n_color;

define _no_documento 						   char(20);
define _cod_marca,_cod_modelo,_cod_agente      char(5);
define v_filtros        					   varchar(255);
define _no_unidad      						   char(5);
define _coaseguro       					   char(2);
define _ano_auto,_cnt       			   			   smallint;
define _estatus_p							   char(10);	
define _no_motor        					   char(30);
define _placa,_cod_contratante,_no_poliza 	   char(10);
define _cod_color,_cod_tipoauto,_cod_tipoprod   char(3);
define _uso_auto 							   char(1);
define _n_corredor,_n_marca,_n_modelo,_n_color char(50);
define _n_tipoauto                             char(50);
define _n_cliente							   varchar(100);
define _v_i,_v_f 							   date;

CALL sp_pro03("001","001",a_fecha,"002,020,023;") RETURNING v_filtros;  --crea tabla temporal temp_perfil

foreach	--POLIZAS VIGENTES
	select no_poliza,
		   no_documento
	  into _no_poliza,
		   _no_documento
	  from temp_perfil
	 where seleccionado = 1
	 
	select decode(estatus_poliza,1,'VIGENTE',2,'CANCELADA',3,'VENCIDA',4,'ANULADA'),
		   vigencia_inic,
		   vigencia_final,
		   cod_contratante,
		   cod_tipoprod
	  into _estatus_p,
		   _v_i,
		   _v_f,
		   _cod_contratante,
		   _cod_tipoprod
	  from emipomae
	 where no_poliza = _no_poliza;
	
	select nombre
	  into _n_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;
	
	let _coaseguro = "";
	if _cod_tipoprod in('001','002') then
		let _coaseguro = 'SI';
	else
		let _coaseguro = 'NO';
	end if
	 
	foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach;
	end foreach
	
	select nombre
	  into _n_corredor
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	foreach	--UNIDADES DE LA POLIZA CON SU MOTOR
		select no_motor,
			   no_unidad,
			   uso_auto
		  into _no_motor,
			   _no_unidad,
			   _uso_auto
		  from emiauto
		 where no_poliza = _no_poliza
		 
		foreach	--TABLA DE MODELOS ESPECIFICOS A BUSCAR
			select cod_modelo
			  into _cod_modelo
			  from deivid_tmp:modelos
			 order by cod_modelo 

			select count(*)
			  into _cnt
			  from emivehic
			 where no_motor   = _no_motor
			   and cod_modelo = _cod_modelo;

			if _cnt is null then 
				let _cnt = 0;
			end if
			if _cnt = 0 then
				continue foreach;
			end if

			select cod_marca,
				   ano_auto,
				   placa,
				   cod_color
			  into _cod_marca,
				   _ano_auto,
				   _placa,
				   _cod_color
			  from emivehic
			 where no_motor = _no_motor;
			 
			select nombre into _n_marca from emimarca where cod_marca = _cod_marca;
			select nombre,cod_tipoauto into _n_modelo,_cod_tipoauto from emimodel where cod_modelo = _cod_modelo;
			select nombre into _n_color from emicolor where cod_color = _cod_color;
			select nombre into _n_tipoauto from emitiaut where cod_tipoauto = _cod_tipoauto;
			
			return _no_documento,_estatus_p,_v_i,_v_f,_cod_contratante,_n_cliente,_cod_agente,_n_corredor,_coaseguro,_no_unidad,_cod_marca,_n_marca,
				   _cod_modelo,_n_modelo,_n_tipoauto,_uso_auto,_ano_auto,_no_motor,_placa,_n_color with resume;
		end foreach
	end foreach
end foreach

drop table temp_perfil;
END PROCEDURE;
