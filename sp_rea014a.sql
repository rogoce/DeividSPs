-- Creado    : 05/03/2010 - Autor: Henry Giron
-- execute procedure sp_rea014("2009-01","2009-03")
-- SIS v.2.0 - DEIVID, S.A.
drop procedure sp_rea014a;
create procedure sp_rea014a(a_periodo1 char(7), a_periodo2 char(7)) 
returning   char(20),
			char(50),
			dec(16,2),
			dec(5,2),
			dec(16,2),
			char(10),
			char(1),
			char(50),
			char(5),
			char(3),
			char(5),
			dec(16,2),
			dec(9,6),
			char(3),
			char(50),
			dec(16,2),
			dec(16,2),
			dec(5,2);
{
POLIZA	ASEGURADO	PRIMA SUSCRITA	factura %COM_A_CORREDOR	REASEG_CEDIDO	%COM_DE_REASEG	contrato TIPO_CONTRATO	en caso de facultativos indicar reasegurador
}
define _no_poliza			char(10);
define _no_endoso			char(5);
define _no_documento		char(20);						
define _bandera				char(20);
define _cod_cliente			char(10);
define _nombre_cliente		char(50);
define _cod_contrato        char(5);
define _cod_cober_reas      char(3);
define _prima               decimal(16,2);
define _no_unidad       	char(5);
define _tipo_contrato		smallint;
define _cod_coasegur        char(3);
define _nombre_coasegur     varchar(50);
define _porc_cont_partic    decimal(9,6);
define _porc_partic_agt     decimal(9,6);
define _porc_comis_ase      decimal(9,6);
define _monto_reas          decimal(16,2);
define _retenida            decimal(16,2);
define _porc_comis_agt      dec(9,6);
define _cantidad			smallint;
define _prima_suscrita		dec(16,2);
define _porc_comision		dec(9,6);
define _comision		    dec(16,2);
define _prima_cedida		dec(16,2);
define _prima_cedida_tot    dec(16,2);
define _prima_cedida_rep	dec(16,2);
define _nombre_coas			char(50);
define _no_factura			char(10);
define _desc_tipo_contrato	char(50);
define _cod_ramo			char(3);
define _terremoto			smallint;
define _porc_partic			dec(9,6);

set isolation to dirty read;

--set debug file to "sp_rea014.trc";
--trace on;

create temp table tmp_aud1(
no_documento   			char(20),
asegurado	    		char(50),
prima_suscrita  		dec(16,2) default 0,
porc_comis_corredor		dec(5,2)  default 0,
prima_cedida_det		dec(16,2) default 0,
porc_rease      		dec(16,2) default 0,
tipo_contrato			char(1),
reas_facultativo		char(50),
cod_contrato    		char(5),
cod_reasegur    		char(3),
no_unidad				char(5),
comision_reas			dec(16,2) default 0,
porc_comision  			dec(9,6)  default 0,
no_factura				char(10),
cod_cobertura           CHAR(3),
prima_cedida_tot		dec(16,2) default 0,
prima_cedida_rep		dec(16,2) default 0,
porc_parti_reas		    dec(5,2)  default 0)  WITH NO LOG;
--PRIMARY KEY(no_documento, cod_contrato, cod_reasegur, tipo_contrato, no_unidad)) WITH NO LOG;

foreach
 select no_poliza,
        no_endoso,
		prima_suscrita,
		prima_retenida,
		no_factura
   into _no_poliza,
        _no_endoso,
		_prima_suscrita,
		_retenida,
		_no_factura
   from endedmae
  where periodo     >= a_periodo1
    and periodo     <= a_periodo2
--	and no_poliza    = '539461'
	and actualizado = 1

	 let _prima_cedida = _prima_suscrita - _retenida;

	select no_documento,
	       cod_contratante,
		   cod_ramo
	  into _no_documento,
	       _cod_cliente,
		   _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	 foreach
		 Select	porc_comis_agt
	 	   Into	_porc_comis_agt
		   From emipoagt
		  Where	no_poliza = _no_poliza

		  exit foreach;
	end foreach

	foreach
	 select f.cod_contrato,
	        f.cod_cober_reas,
			f.prima,
  			f.no_unidad
	   into	_cod_contrato,
	        _cod_cober_reas,  
			_prima,
			_no_unidad
	   from emifacon f, endeduni u
	  where u.no_poliza = _no_poliza
	    and u.no_endoso = _no_endoso
		and f.no_poliza = u.no_poliza
		and f.no_endoso = u.no_endoso
		and f.no_unidad = u.no_unidad
		and f.prima     <> 0.00

        select tipo_contrato
          into _tipo_contrato
          from reacomae
         where cod_contrato = _cod_contrato;

			if _tipo_contrato = 1 then  -- No trabajar retencion
			   continue foreach;
		    elif _tipo_contrato = 3 then  --facultativo

				foreach
					select cod_coasegur
					  into _cod_coasegur
					  from emifafac
				     where no_poliza      = _no_poliza
				       and no_endoso      = _no_endoso
				       and cod_contrato   = _cod_contrato
				       and cod_cober_reas = _cod_cober_reas
			           and no_unidad      = _no_unidad
			           						
					select nombre
					  into _nombre_coas
					  from emicoase
					 where cod_coasegur = _cod_coasegur;
		
		 			INSERT INTO tmp_aud1(
					no_documento,
					asegurado,
					prima_suscrita,
					porc_comis_corredor,
					prima_cedida_det,
					porc_rease,
					tipo_contrato,
					reas_facultativo,
					cod_contrato,
					cod_reasegur,
					no_unidad,
					no_factura,
					cod_cobertura,
					prima_cedida_tot)										
					VALUES(_no_documento,
					_nombre_cliente,
					_prima_suscrita,
					_porc_comis_agt,
					0,
					0,
					_tipo_contrato,
					_nombre_coas,
					_cod_contrato,
					_cod_coasegur,
					_no_unidad,
					_no_factura,
					_cod_cober_reas,
					0);
		
				end foreach
			else

				 select count(*)
				   into _cantidad
				   from reacoase
			      where cod_contrato   = _cod_contrato
			        and cod_cober_reas = _cod_cober_reas;

				if _cantidad = 0 then

		 			INSERT INTO tmp_aud1(
					no_documento,
					asegurado,
					prima_suscrita,
					porc_comis_corredor,
					prima_cedida_det,
					porc_rease,
					tipo_contrato,
					reas_facultativo,
					cod_contrato,
					cod_reasegur,
					no_unidad,
					no_factura,
					cod_cobertura,
					prima_cedida_tot)
					VALUES(_no_documento,
					_nombre_cliente,
					_prima_suscrita,
					_porc_comis_agt,
					0,
					0,
					_tipo_contrato,
					"",
					_cod_contrato,
					"" ,
					_no_unidad,
					_no_factura,
					_cod_cober_reas,
					0
					);

				else

					foreach
					 select cod_coasegur,
					        porc_cont_partic,
					        porc_comision					
					   into _cod_coasegur,
					        _porc_cont_partic,
							_porc_comision
					   from reacoase
				      where cod_contrato   = _cod_contrato
				        and cod_cober_reas = _cod_cober_reas

							let _monto_reas = _prima_cedida * _porc_cont_partic / 100; 
							let _terremoto = 0;

							if _cod_ramo = "001" or _cod_ramo = "003" then
								select es_terremoto 
								  into _terremoto
								  from reacobre
								 where cod_ramo = _cod_ramo
								   and cod_cober_reas = _cod_cober_reas; 

									if _terremoto = 1 then
									   let _monto_reas = 0.3 * _monto_reas ;
									else
									   let _monto_reas = 0.7 * _monto_reas ;
									end if
							end if

							let _comision   = _monto_reas * _porc_comision / 100;   

							select nombre
							  into _nombre_coas
							  from emicoase
							 where cod_coasegur = _cod_coasegur; 

				 			INSERT INTO tmp_aud1(
							no_documento,
							asegurado,
							prima_suscrita,
							porc_comis_corredor,
							prima_cedida_det,
							porc_rease,
							tipo_contrato,
							reas_facultativo,
							cod_contrato,
							cod_reasegur,
							no_unidad,
							comision_reas,
							porc_comision,
							no_factura,
							cod_cobertura,
							prima_cedida_tot,
							prima_cedida_rep,
							porc_parti_reas)
							VALUES(_no_documento,
							_nombre_cliente,
							_prima_suscrita,
							_porc_comis_agt,
							_monto_reas,
							_porc_comision,
							_tipo_contrato,
							_nombre_coas,
							_cod_contrato,
							_cod_coasegur,
							_no_unidad,
							_comision,
							_porc_comision,
							_no_factura,
							_cod_cober_reas,
							_prima_cedida,
							_prima_cedida,
							_porc_cont_partic);

					end foreach		   
				end if
			end if
	end foreach
end foreach

let _bandera = "0";

foreach
 select no_documento,
		asegurado,
		prima_suscrita,
		porc_comis_corredor,
		prima_cedida_det,
		porc_rease,
		tipo_contrato,
		reas_facultativo,
		cod_contrato,
		cod_reasegur,
		no_unidad,
		comision_reas,
		porc_comision,
		no_factura,
		cod_cobertura,
		prima_cedida_tot,
		prima_cedida_rep,
		porc_parti_reas
   into _no_documento,
		_nombre_cliente,
		_prima_suscrita,
		_porc_partic_agt,
		_monto_reas,
		_porc_cont_partic,
		_tipo_contrato,
		_nombre_coas,
		_cod_contrato,
		_cod_coasegur,
		_no_unidad,
		_comision,
		_porc_comision,
		_no_factura,
		_cod_cober_reas,
		_prima_cedida_tot,
		_prima_cedida_rep,
		_porc_partic
   from tmp_aud1
   order by 1,2,11,9,14,15

		if _bandera = _no_documento then
			let _prima_suscrita = 0;
			let	_porc_partic_agt = 0;
			let _prima_cedida_tot = 0;
		else
			let _bandera = _no_documento;
		end if

		if  _tipo_contrato = 2 then 
			let _desc_tipo_contrato = "Fronting";
		elif _tipo_contrato = 3 then 
			let _desc_tipo_contrato = "Facultativo";
		elif _tipo_contrato = 4 then 
			let _desc_tipo_contrato = "Normal";
		elif _tipo_contrato = 5 then 
			let _desc_tipo_contrato = "Cuota Parte";
		elif _tipo_contrato = 6 then 
			let _desc_tipo_contrato = "Exceso de Perdida";
		elif _tipo_contrato = 7 then 
			let _desc_tipo_contrato = "Excedente";
		end if


	return _no_documento,
		   _nombre_cliente,
		   _prima_suscrita,
		   _porc_partic_agt,
		   _monto_reas,
		   _no_factura,
		   _tipo_contrato,
		   _nombre_coas,
		   _cod_contrato,
		   _cod_coasegur,
		   _no_unidad,
		   _comision,
		   _porc_comision,
		   _cod_cober_reas,
		   _desc_tipo_contrato,
		   _prima_cedida_tot,
		   _prima_cedida_rep,
		   _porc_partic		   		   
		   with resume;

end foreach

drop table tmp_aud1;

end procedure
