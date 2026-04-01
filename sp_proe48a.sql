-- Creado    : 21/07/2010 - Autor: Henry Giron
-- execute procedure sp_proe48("2010-07")
-- SIS v.2.0 - DEIVID, S.A.
DROP PROCEDURE sp_proe48a;
CREATE PROCEDURE sp_proe48a(a_periodo_desde char(7), a_periodo_hasta char(7))
RETURNING CHAR(3),			 --cod_ramo 
		  char(10),			 --no_poliza 
		  char(5),			 --no_endoso 
		  char(5),			 --no_unidad 
		  char(20),			 --no_documento 
		  date,				 --vig_desde_end 
		  date,				 --vig_hasta_end 
		  date,				 --fecha_emision 
		  dec(16,2),		 --prima_suscrita 
		  dec(16,2),		 --prima_sus_pol 
		  dec(16,2),		 --suma_asegurada 
		  dec(16,2),		 --suma_aseg_pol 
		  dec(9,2),			 --porc_partic_suma 
		  dec(9,2),			 --porc_partic_prima 
		  char(50),			 --n_tipoprod 
		  char(50),			 --nombre_cliente 
		  char(5),			 --cod_contrato 
		  char(50),			 --n_contrato 
		  char(3),			 --cod_cobertura 
		  char(50),			 --n_cobertura 
		  smallint,			 --orden 
		  smallint,			 --tipo_contrato 
		  char(15),			 --n_tipo_contrato 
		  dec(16,2),		 --porc_prima 
		  dec(16,2),		 --porc_suma
		  char(50),          --desc_ramo
		  dec(16,2),         --ret_x 
		  dec(16,2),         --exc_x 
		  dec(16,2),         --fac_x 
		  dec(16,2),         --otr_x
		  varchar(50);       --ase_x	  
		  		     

define _cod_cobertura    	char(3);
define _desc_ramo           char(50);
define _cod_contratante  	char(10);	
define _cod_contrato     	char(5);
define _cod_ramo         	char(3);
define _cod_tipoprod     	char(3);
define _n_cobertura      	char(50);
define _n_contrato       	char(50);
define _n_tipo_contrato  	char(15);
define _n_tipoprod      	char(50);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _no_documento    	char(20);
define _periodo		       	char(7);
define _no_unidad       	char(5);
define _nombre_cliente		char(50);
define _orden   			smallint;
define _porc_partic_suma	decimal(9,6);
define _porc_partic_prima	decimal(9,6);
define _porc_prima			dec(16,2);
define _porc_suma       	dec(16,2);
define _prima_fact			dec(16,2);
define _prima_sus_pol		dec(16,2);
define _prima_suscrita		dec(16,2);
define _suma_aseg_pol		dec(16,2);
define _suma_asegurada  	dec(16,2);
define _tipo_contrato   	smallint;
define _vig_desde_end		date;
define _vig_hasta_end		date;
define _fecha_emision		date;
define _fecha_hoy			date;
define _ret_x				dec(16,2);
define _exc_x				dec(16,2);
define _fac_x				dec(16,2);
define _otr_x				dec(16,2);
define _ase_x     			varchar(50);
define _cod_coasegur        char(3);
define _nombre_coas         varchar(50);

--SOLICITA:  Numero de poliza, asegurado, vigencia, tipo de riesgo (incenio, Rc , etc) y su distribucion de reaseguro

SET ISOLATION TO DIRTY READ;

create temp table tmp_facultativo(
cod_ramo	  CHAR(3),
no_poliza	  char(10),
no_endoso	  char(5),
no_unidad     char(5),
no_documento  char(20),
vig_desde_end date,
vig_hasta_end date,
fecha_emision date,
prima_unidad  dec(16,2),
prima_sus     dec(16,2),
suma_unidad	  dec(16,2),
suma		  dec(16,2),
porc_prima	  dec(16,2),
porc_suma	  dec(16,2),
seleccionado  smallint) with no log;


create temp table tmp_distribuir
(cod_ramo	 	CHAR(3),
no_poliza	 	char(10),
no_endoso	 	char(5),
no_unidad    	char(5),
no_documento 	char(20),
cod_contrato	char(5),
n_contrato		char(50),
cod_cobertura	char(3),
n_cobertura		char(50),
tipo_contrato	smallint,
n_tipo_contrato	char(15),
porc_prima		dec(16,2),
porc_suma 		dec(16,2),
prima_fact 		dec(16,2),
orden           smallint) with no log;

let _fecha_hoy   = today;

foreach
	 select	distinct mae.no_poliza,
	        mae.no_endoso,
	        mae.no_documento,
			mae.vigencia_inic,
			mae.vigencia_final,
			mae.fecha_emision,
			mae.periodo
	   into _no_poliza,
	        _no_endoso,
	        _no_documento,
			_vig_desde_end,
			_vig_hasta_end,
			_fecha_emision,
			_periodo
	   from endedmae mae
	  inner join emifafac fac on fac.no_poliza = mae.no_poliza and mae.no_endoso = fac.no_endoso
	  where mae.periodo between a_periodo_desde and a_periodo_hasta
		and mae.actualizado = 1
	   order by mae.fecha_emision, mae.no_documento

	     let _no_poliza = sp_sis21(_no_documento);

	  select cod_ramo,suma_asegurada,prima_suscrita
	    into _cod_ramo,_suma_aseg_pol,_prima_sus_pol
	    from emipomae
	   where no_poliza = _no_poliza;

		foreach
			select no_unidad,
			       suma_asegurada,
				   prima_suscrita
			  into _no_unidad,
			       _suma_asegurada,
				   _prima_suscrita
			  from emipouni
			 where no_poliza = _no_poliza
	 			
            insert into tmp_facultativo (cod_ramo,no_poliza,no_endoso,no_unidad,no_documento,vig_desde_end,vig_hasta_end,fecha_emision,prima_unidad,prima_sus,suma_unidad,suma,porc_prima,porc_suma,seleccionado)
			values (_cod_ramo,_no_poliza, _no_endoso, _no_unidad,_no_documento,_vig_desde_end,_vig_hasta_end,_fecha_emision,_prima_suscrita,_prima_sus_pol,_suma_asegurada, _suma_aseg_pol, 0.00, 0.00,0);

			 foreach
				select cod_contrato,
				       cod_cober_reas,
					   porc_partic_suma,
					   porc_partic_prima,
	            	   prima,
					   orden
				  into _cod_contrato,
				       _cod_cobertura,
					   _porc_partic_suma,
					   _porc_partic_prima,
					   _prima_fact,
					   _orden
				  from emifacon
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and no_unidad = _no_unidad

				select tipo_contrato,nombre
				  into _tipo_contrato,_n_contrato
				  from reacomae
				 where cod_contrato = _cod_contrato;

		         select nombre
		           into _n_cobertura
		           from reacobre
		          where cod_cober_reas = _cod_cobertura;

				let _porc_prima = _porc_partic_prima;
				let	_porc_suma	= _porc_partic_suma;

				if  _tipo_contrato = 1 then 
					let _n_tipo_contrato = "Retencion";
				elif _tipo_contrato = 2 then 
					let _n_tipo_contrato = "Facultativo";
				elif _tipo_contrato = 3 then 
					let _n_tipo_contrato = "Facultativo";
				elif _tipo_contrato = 4 then 
					let _n_tipo_contrato = "Normal";
				elif _tipo_contrato = 5 then 
					let _n_tipo_contrato = "Cuota Parte";
				elif _tipo_contrato = 6 then 
					let _n_tipo_contrato = "Exceso de Perdida";
				elif _tipo_contrato = 7 then 
					let _n_tipo_contrato = "Excedente";
				end if

				insert into tmp_distribuir (cod_ramo,no_poliza,no_endoso,no_unidad,no_documento,cod_contrato,n_contrato,cod_cobertura,n_cobertura,tipo_contrato,n_tipo_contrato,porc_prima,porc_suma,orden,prima_fact)
				values (_cod_ramo,_no_poliza,_no_endoso,_no_unidad,_no_documento,_cod_contrato,_n_contrato,_cod_cobertura,_n_cobertura,_tipo_contrato,_n_tipo_contrato,_porc_prima,_porc_suma,_orden,_prima_fact)	;

				if _tipo_contrato = 2 or _tipo_contrato = 3	then
						update tmp_facultativo
						   set seleccionado = 1
						 where no_poliza = _no_poliza 
						   and no_endoso = _no_endoso
						   and no_unidad = _no_unidad;
				end if


			 end foreach
		end foreach
end foreach

foreach
	select cod_ramo,
	       no_poliza,
	       no_endoso,
	       no_unidad,
	       no_documento,
		   prima_unidad,
		   prima_sus,
		   suma_unidad,
		   suma,
		   porc_prima,
		   porc_suma,
		   vig_desde_end,
		   vig_hasta_end,
		   fecha_emision
	  into _cod_ramo,
	       _no_poliza,
	       _no_endoso,
	       _no_unidad,
	       _no_documento,
		   _prima_suscrita,
		   _prima_sus_pol,
		   _suma_asegurada,
		   _suma_aseg_pol,
		   _porc_partic_suma,
		   _porc_partic_prima,
		   _vig_desde_end,
		   _vig_hasta_end,
		   _fecha_emision
	  from tmp_facultativo
	 where seleccionado = 1

	let _no_poliza = sp_sis21(_no_documento);

	select cod_tipoprod,
	       cod_contratante
	  into _cod_tipoprod,
	       _cod_contratante
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select nombre
	  into _n_tipoprod
	  from emitipro
	 where cod_tipoprod = _cod_tipoprod;

    select nombre
      into _desc_ramo
      from prdramo
     where cod_ramo = _cod_ramo;

	   let _ret_x =   0;
	   let _exc_x =   0;
	   let _fac_x =	  0;
	   let _otr_x =	  0;
	   let _ase_x = " ";

	 foreach
	select cod_contrato,
			n_contrato,
			cod_cobertura,
			n_cobertura,
			orden,
			tipo_contrato,
			n_tipo_contrato,
			porc_prima,
			porc_suma
		  into _cod_contrato,
			_n_contrato,
			_cod_cobertura,
			_n_cobertura,
			_orden,
			_tipo_contrato,
			_n_tipo_contrato,
			_porc_prima,
			_porc_suma
	  from tmp_distribuir
	  where cod_ramo = _cod_ramo
	    and no_poliza = _no_poliza
	    and no_endoso = _no_endoso
	    and no_unidad = _no_unidad
	    and no_documento  = _no_documento
		order by 1,3,5

			if _tipo_contrato = 1 then
			   let _ret_x =   _ret_x + _porc_prima ;
			elif _tipo_contrato = 2 or _tipo_contrato = 3 then
				   let _ase_x = " ";
				   let _fac_x =	  _fac_x + _porc_prima ;

				select cod_coasegur
				  into _cod_coasegur
				  from emifafac
			     where no_poliza      = _no_poliza
			       and no_endoso      = _no_endoso
			       and cod_contrato   = _cod_contrato
			       and cod_cober_reas = _cod_cobertura
		           and no_unidad      = _no_unidad;
					
				select nombre
				  into _nombre_coas
				  from emicoase
				 where cod_coasegur = _cod_coasegur ;

				   let _ase_x = _nombre_coas ;

			elif _tipo_contrato = 6 or _tipo_contrato = 7 then
			   let _exc_x =   _exc_x + _porc_prima ;
			else
			   let _otr_x =   _otr_x + _porc_prima ;
			end if   

	  end foreach

		return _cod_ramo,
		       _no_poliza,
		       _no_endoso,
		       _no_unidad,
		       _no_documento,
			   _vig_desde_end,
			   _vig_hasta_end,
			   _fecha_emision,
			   _prima_suscrita,
			   _prima_sus_pol,
			   _suma_asegurada,
			   _suma_aseg_pol,
			   _porc_partic_suma,
			   _porc_partic_prima,
			   _n_tipoprod,
			   _nombre_cliente,
			   _cod_contrato,
			   _n_contrato,
			   _cod_cobertura,
			   _n_cobertura,
			   _orden,
			   _tipo_contrato,
			   _n_tipo_contrato,
			   _porc_prima,
			   _porc_suma,
			   _desc_ramo,
			   _ret_x,
			   _exc_x,
			   _fac_x,
			   _otr_x,
			   _ase_x
			   with resume;


end foreach

drop table tmp_facultativo;
drop table tmp_distribuir;


END PROCEDURE;	  	