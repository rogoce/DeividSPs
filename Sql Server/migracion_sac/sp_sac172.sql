-- Detalle de las facturas para revision contable

-- Creado    : 08/02/2010 - Autor: Demetrio Hurtado Almanza 

-- SIS v.2.0 -- -- DEIVID, S.A.

drop procedure sp_sac172;

create procedure "informix".sp_sac172(a_periodo char(7))
returning char(20),
          char(10),
		  char(50),
		  date,
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  date,
		  char(3),
		  char(50),
		  dec(5,2),
		  char(5),
		  char(5),---
		  varchar(50),
		  decimal(9,6),
		  decimal(9,6),
		  char(3),
		  varchar(50),
		  decimal(5,2),
		  varchar(25),
		  varchar(25),
		  varchar(25),
		  char(3),
		  varchar(50),
		  decimal(7,4);

define _nombre_ramo		char(50);
define _nombre_cliente	char(50);

define _no_documento	char(20);

define _no_factura		char(10);
define _no_poliza		char(10);
define _cod_cliente		char(10);
define _cod_agente		char(10);


define _periodo			char(7);
define _periodo2		char(7);

define _no_endoso		char(5);

define _cod_ramo		char(3);

define _tipo_agente		char(1);

define _fecha			date;
define _fecha_anulado	date;

define _prima_suscrita	dec(16,2);
define _prima_neta		dec(16,2);

define _porc_comis_agt  dec(5,2);
define _porc_partic_agt	dec(5,2);

define _no_unidad       char(5);

define _cod_cober_reas       char(3);
define _cod_contrato         char(5);  -- 1
define _nombre_contrato 	 varchar(50); -- 2
define _porc_partic_suma     decimal(9,6); -- 3
define _porc_partic_prima    decimal(9,6); -- 4
define _suma_asegurada       decimal(16,2);
define _prima                decimal(16,2);
define _cod_coasegur         char(3);	  --4.1
define _nombre_coasegur      varchar(50); --4.5
define _porc_cont_partic     decimal(9,6);
define _porc_comision        decimal(5,2); -- 5
define _tiene_comision		 smallint;
define _nombre_calculo       varchar(25); --6
define _clase_contrato 		 char(1);
define _nombre_clase         varchar(25); --7
define _tipo_reaseguro		 char(1);
define _nombre_tipo          varchar(25); --8
define _cod_coasegur_m       char(3);  --9
define _nombre_coasegur_m    varchar(50); --10
define _porc_partic_coas     decimal(7,4); -- 11
define _prima_retenida		 dec(16,2);

define _cnt                  smallint;

set isolation to dirty read;

foreach
 select no_documento,
        no_factura,
		fecha_emision,
		periodo,
		prima_suscrita,
		prima_neta,
		no_poliza,
		no_endoso,
		prima_retenida
   into _no_documento,
        _no_factura,
		_fecha_anulado,
		_periodo,
		_prima_suscrita,
		_prima_neta,
		_no_poliza,
		_no_endoso,
		_prima_retenida
   from endedmae
  where cod_compania = "001"
    and actualizado  = 1 	
    and periodo      = a_periodo

	select cod_ramo,
	       cod_contratante
	  into _cod_ramo,
	       _cod_cliente
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	-- Periodo y Fecha

	let _periodo2 = sp_sis39(_fecha_anulado);

	if _periodo = _periodo2 then
		let _fecha = _fecha_anulado;
	elif _periodo > _periodo2 then
		let _fecha = MDY(_periodo[6,7], 1, _periodo[1,4]);
	elif _periodo < _periodo2 then
		let _fecha = sp_sis36(_periodo);
	end if

	foreach
	 Select	porc_comis_agt,
			porc_partic_agt,
			cod_agente
	   Into	_porc_comis_agt,
			_porc_partic_agt,
			_cod_agente
	   From endmoage
	  Where	no_poliza = _no_poliza
	    and no_endoso = _no_endoso

		select tipo_agente
		  into _tipo_agente
		  from agtagent
		 where cod_agente = _cod_agente;

		if _tipo_agente = "O" then
			let _porc_comis_agt = 0.00;
		end if

		exit foreach;

	end foreach

	foreach
     select no_unidad
	   into _no_unidad
	   from endeduni
	  where no_poliza = _no_poliza
	    and no_endoso = _no_endoso

		 foreach
		     select cod_cober_reas,
			        cod_contrato,
					porc_partic_suma,
					porc_partic_prima,
					suma_asegurada,
					prima
			   into _cod_cober_reas,
					_cod_contrato,
					_porc_partic_suma,
					_porc_partic_prima,
					_suma_asegurada,
					_prima
			   from emifacon
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso
				and no_unidad = _no_unidad
			  order by orden

	         select nombre, clase_contrato, tipo_reaseguro
			   into _nombre_contrato, _clase_contrato, _tipo_reaseguro
			   from reacomae
			  where cod_contrato = _cod_contrato;


             if _clase_contrato	= "P" then
				let _nombre_clase = "Proporcional";
             elif _clase_contrato	= "N" then
				let _nombre_clase = "No Proporcional";
			 else
				let _nombre_clase = "Facultativo";
			 end if

             if _tipo_reaseguro	= "P" then
				let _nombre_tipo = "Ocurrencia de Perdida";
			 else
				let _nombre_tipo = "Origen de Poliza";
			 end if

	         select tiene_comision
			   into _tiene_comision
			   from reacocob
			  where cod_contrato = _cod_contrato
			    and cod_cober_reas = _cod_cober_reas;

             if _tiene_comision = 0 then
				let _nombre_calculo = "No Tiene";
			 elif _tiene_comision = 1 then
				let _nombre_calculo = "Por Contrato";
		     else
				let _nombre_calculo = "Por Reasegurador";
			 end if

	         let _cnt = 0;

	         select count(*)
			   into _cnt
			   from	reacoase
			  where cod_contrato = _cod_contrato
			    and cod_cober_reas = _cod_cober_reas;

	         if _cnt > 0 then
				 foreach
					 select cod_coasegur, porc_cont_partic, porc_comision  
					   into _cod_coasegur, _porc_cont_partic, _porc_comision
					   from reacoase  
					  where cod_contrato = _cod_contrato
					    and cod_cober_reas = _cod_cober_reas

                      select nombre
					    into _nombre_coasegur
						from emicoase
					   where cod_coasegur = _cod_coasegur;

	         		let _cnt = 0;

			         select count(*)
					   into _cnt
					   from	endcoama
					  where no_poliza = _no_poliza
					    and no_endoso = _no_endoso;

			         if _cnt > 0 then
					 	foreach
						  select cod_coasegur,   
						         porc_partic_coas
						    into _cod_coasegur_m,
						      	 _porc_partic_coas
						    from endcoama  
						   where no_poliza = _no_poliza
						     and no_endoso = _no_endoso

                          select nombre
						    into _nombre_coasegur_m
							from emicoase
						   where cod_coasegur = _cod_coasegur_m;

						return _no_documento,
						       _no_factura,
							   _nombre_cliente,
							   _fecha_anulado,
							   _prima_neta,
							   _prima_suscrita,
							   _prima_retenida,
							   _fecha,
							   _cod_ramo,
							   _nombre_ramo,
							   _porc_comis_agt,
							   _no_unidad,
							   _cod_contrato,
							   _nombre_contrato,
							   _porc_partic_suma,
							   _porc_partic_prima,
							   _cod_coasegur,   
							   _nombre_coasegur,
							   _porc_comision,
							   _nombre_calculo,
							   _nombre_clase,
							   _nombre_tipo,
							   _cod_coasegur_m,
							   _nombre_coasegur_m, 
							   _porc_partic_coas
							   with resume;

					    end foreach
					  else
						return _no_documento,
						       _no_factura,
							   _nombre_cliente,
							   _fecha_anulado,
							   _prima_neta,
							   _prima_suscrita,
							   _prima_retenida,
							   _fecha,
							   _cod_ramo,
							   _nombre_ramo,
							   _porc_comis_agt,
							   _no_unidad,
							   _cod_contrato,
							   _nombre_contrato,
							   _porc_partic_suma,
							   _porc_partic_prima,
							   _cod_coasegur,   
							   _nombre_coasegur,
							   _porc_comision,
							   _nombre_calculo,
							   _nombre_clase,
							   _nombre_tipo,
							   null,
							   null, 
							   0.00
							   with resume;
					  end if

				 end foreach
		     else

		         let _cnt = 0;

		         select count(*)
				   into _cnt
				   from	endcoama
				  where no_poliza = _no_poliza
				    and no_endoso = _no_endoso;

		         if _cnt > 0 then
				 	foreach
					  select cod_coasegur,   
					         porc_partic_coas
					    into _cod_coasegur_m,
					      	 _porc_partic_coas
					    from endcoama  
					   where no_poliza = _no_poliza
					     and no_endoso = _no_endoso

                          select nombre
						    into _nombre_coasegur_m
							from emicoase
						   where cod_coasegur = _cod_coasegur_m;

						return _no_documento,
						       _no_factura,
							   _nombre_cliente,
							   _fecha_anulado,
							   _prima_neta,
							   _prima_suscrita,
							   _prima_retenida,
							   _fecha,
							   _cod_ramo,
							   _nombre_ramo,
							   _porc_comis_agt,
							   _no_unidad,
							   _cod_contrato,
							   _nombre_contrato,
							   _porc_partic_suma,
							   _porc_partic_prima,
							   null,   
							   null,
							   0.00,
							   _nombre_calculo,
							   _nombre_clase,
							   _nombre_tipo,
							   _cod_coasegur_m,
							   _nombre_coasegur_m, 
							   _porc_partic_coas
							   with resume;


				    end foreach

	              else

					return _no_documento,
					       _no_factura,
						   _nombre_cliente,
						   _fecha_anulado,
						   _prima_neta,
						   _prima_suscrita,
						   _prima_retenida,
						   _fecha,
						   _cod_ramo,
						   _nombre_ramo,
						   _porc_comis_agt,
						   _no_unidad,
						   _cod_contrato,
						   _nombre_contrato,
						   _porc_partic_suma,
						   _porc_partic_prima,
						   null,   
						   null,
						   0.00,
						   _nombre_calculo,
						   _nombre_clase,
						   _nombre_tipo,
						   null,
						   null, 
						   0.00
						   with resume;
				  end if
			 end if
	      
	       

		end foreach

	end foreach	
end foreach	

end procedure
