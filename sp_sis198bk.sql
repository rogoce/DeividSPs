-- Procedimiento para convertir polizas de AUTOMOVIL a AUTOMOVIL FLOTA --
-- 
-- Creado    : 18/08/2014 - Autor: Amado Perez Mendoza.
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sis198;

create procedure "informix".sp_sis198(a_documento CHAR(20))
returning integer, 
          char(100),
          char(30);
		  	
define _no_poliza      char(10); 
define _no_endoso	   char(5);
define _no_unidad      char(5);
define _cod_subramo    char(3);
define _valor_flota    varchar(10);
define _cod_producto   char(5);
define _cod_cobertura  char(5);
define _cod_cober_reas char(3);
define _orden          smallint;
define _cod_contrato         char(5);
define _porc_partic_suma     decimal(9,6);
define _porc_partic_prima    decimal(9,6);

define _cod_coasegur         char(3);
define _porc_partic_reas     decimal(9,6);
define _porc_comis_fac       decimal(7,4);
define _porc_impuesto        decimal(5,2);
define _suma_asegurada       decimal(16,2);
define _prima                decimal(16,2);

define _impreso              smallint;
define _fecha_impresion      date;
define _no_cesion            char(10);
define _subir_bo             smallint;
define _monto_comision       decimal(16,2);
define _monto_impuesto       decimal(16,2);


define _no_remesa            char(10);
define _renglon              smallint;
define _cod_compania         char(3);
define _cod_sucursal         char(3);
define _no_tranrec           char(10);
define _cod_recibi_de        char(10);
define _no_reclamo, _no_reclamo2           char(10);
define _no_recibo            char(10);
define _doc_remesa           char(30);
define _tipo_mov             char(1);
define _monto                decimal(16,2);
define _prima_neta           decimal(16,2);
define _impuesto             decimal(16,2);
define _monto_descontado     decimal(16,2);
define _comis_desc           smallint;
define _desc_remesa          varchar(100,0);
define _saldo                decimal(16,2);
define _periodo              char(7);
define _fecha                date;
define _actualizado          smallint;
define _cod_agente           char(5);
define _cod_auxiliar         char(5);
define _sac_asientos         smallint;
define _flag_web_corr        smallint;
define _no_recibo2           char(10);
define _gastos_manejo        decimal(16,2);
define _cod_ruta             char(5);


define _error_cod	integer;
define _error_isam	integer;
define _error_desc	char(100);
define _no_motor    varchar(30);
define _cnt         integer;
define _no_cambio   smallint; 

create temp table tmp_emireaco(
no_poliza            char(10),
no_unidad            char(5),
no_cambio            smallint,
cod_cober_reas       char(3),
orden                smallint,
cod_contrato         char(5),
porc_partic_suma     decimal(9,6),
porc_partic_prima    decimal(9,6)
) WITH NO LOG; 

create temp table tmp_emifafac(
no_poliza            char(10),
no_endoso            char(5),
no_unidad            char(5),
cod_cober_reas       char(3),
orden                smallint,
cod_contrato         char(5),
cod_coasegur         char(3),
porc_partic_reas     decimal(9,6),
porc_comis_fac       decimal(7,4),
porc_impuesto        decimal(5,2),
suma_asegurada       decimal(16,2),
prima                decimal(16,2),
impreso              smallint,
fecha_impresion      date,
no_cesion            char(10),
subir_bo             smallint,
monto_comision       decimal(16,2),
monto_impuesto       decimal(16,2)
) WITH NO LOG; 

create temp table tmp_emiglofa(
no_poliza            char(10),
no_endoso            char(5),
orden                smallint,
cod_contrato         char(5),
cod_coasegur         char(3),
porc_partic_reas     decimal(9,6),
porc_comis_fac       decimal(5,2),
porc_impuesto        decimal(5,2),
suma_asegurada       decimal(16,2),
prima                decimal(16,2)
) WITH NO LOG;

create temp table tmp_recreafa(
no_reclamo           char(10),
orden                smallint,
cod_contrato         char(5),
cod_coasegur         char(3),
porc_partic_reas     decimal(9,6),
cod_cober_reas       char(3)
) WITH NO LOG;

create temp table tmp_cobredet(
no_remesa            char(10),
renglon              smallint,
cod_compania         char(3),
cod_sucursal         char(3),
no_poliza            char(10),
no_unidad            char(5),
no_tranrec           char(10),
cod_recibi_de        char(10),
no_reclamo           char(10),
cod_cobertura        char(5),
no_recibo            char(10),
doc_remesa           char(30),
tipo_mov             char(1),
monto                decimal(16,2),
prima_neta           decimal(16,2),
impuesto             decimal(16,2),
monto_descontado     decimal(16,2),
comis_desc           smallint,
desc_remesa          varchar(100,0),
saldo                decimal(16,2),
periodo              char(7),
fecha                date,
actualizado          smallint,
cod_agente           char(5),
cod_auxiliar         char(5),
sac_asientos         smallint,
subir_bo             smallint,
flag_web_corr        smallint,
no_recibo2           char(10),
gastos_manejo        decimal(16,2)
) WITH NO LOG;

set isolation to dirty read;

BEGIN WORK;

begin 
on exception set _error_cod, _error_isam, _error_desc
    rollback work;
	DROP TABLE tmp_emireaco;
	DROP TABLE tmp_emifafac;
  	DROP TABLE tmp_recreafa;
	DROP TABLE tmp_cobredet;
	DROP TABLE tmp_emiglofa;
	return _error_cod, _error_desc, _error_desc;
end exception

--SET DEBUG FILE TO "sp_sis198.trc"; 
--trace on;

foreach with hold
	select no_poliza,
		   cod_subramo
	  into _no_poliza,
		   _cod_subramo
	  from emipomae
	 where no_documento = a_documento

	let _valor_flota = null;

	select valor_flota
	  into _valor_flota
	  from parautflot
	 where tipo_valor = "cod_subramo"
	   and valor_auto = _cod_subramo;

	if _valor_flota is not null and TRIM(_valor_flota) <> "" then
		update emipomae 
		   set cod_ramo    = '023',
			   cod_subramo = _valor_flota
		 where no_poliza   = _no_poliza;
	else
		rollback work;
		DROP TABLE tmp_emireaco;
		DROP TABLE tmp_emifafac;
		DROP TABLE tmp_recreafa;
		DROP TABLE tmp_cobredet;
		DROP TABLE tmp_emiglofa;
		return -1, "cod_subramo",_cod_subramo;
	end if

	foreach with hold
		select cod_ruta,
			   no_endoso,
			   orden
		  into _cod_ruta,
			   _no_endoso,
			   _orden
		  from emigloco
		 where no_poliza = _no_poliza

		if _cod_ruta is null or trim(_cod_ruta) = "" then
			continue foreach;
		end if

	 	let _valor_flota = null;

		select valor_flota
		  into _valor_flota
		  from parautflot
		 where tipo_valor = "cod_ruta"
		   and valor_auto = _cod_ruta;

		if _valor_flota is not null and TRIM(_valor_flota) <> "" then
			update emigloco
			   set cod_ruta = _valor_flota
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and orden     = _orden;
		else
			rollback work;
			DROP TABLE tmp_emireaco;
			DROP TABLE tmp_emifafac;
			DROP TABLE tmp_recreafa;
			DROP TABLE tmp_cobredet;
			DROP TABLE tmp_emiglofa;
			return -1, "emigloco cod_ruta", _cod_ruta;
		end if
	end foreach

	foreach with hold
		select cod_producto,
			   no_unidad,
			   cod_ruta
		  into _cod_producto,
			   _no_unidad,
			   _cod_ruta
		  from emipouni
		 where no_poliza = _no_poliza
		 order by no_unidad

		let _valor_flota = null;

		select valor_flota
		  into _valor_flota
		  from parautflot
		 where tipo_valor = "cod_producto"
		   and valor_auto = _cod_producto;

		if _valor_flota is not null and TRIM(_valor_flota) <> "" then
			update emipouni
			   set cod_producto = _valor_flota
			 where no_poliza    = _no_poliza
			   and no_unidad    = _no_unidad;
	     
			update endeduni
			   set cod_producto = _valor_flota
			 where no_poliza    = _no_poliza
			   and no_unidad    = _no_unidad;
		else
			rollback work;
			DROP TABLE tmp_emireaco;
			DROP TABLE tmp_emifafac;
			DROP TABLE tmp_recreafa;
			DROP TABLE tmp_cobredet;
			DROP TABLE tmp_emiglofa;
			return -1, "cod_producto",_no_poliza;
		end if

		let _valor_flota = null;

		select valor_flota
		  into _valor_flota
		  from parautflot
		 where tipo_valor = "cod_ruta"
		   and valor_auto = _cod_ruta;

		if _valor_flota is not null and TRIM(_valor_flota) <> "" then
			update emipouni
			   set cod_ruta  = _valor_flota
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;

			update endeduni
			   set cod_ruta  = _valor_flota
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad;
		else
			rollback work;
			DROP TABLE tmp_emireaco;
			DROP TABLE tmp_emifafac;
			DROP TABLE tmp_recreafa;
			DROP TABLE tmp_cobredet;
			DROP TABLE tmp_emiglofa;
			return -1, "cod_ruta",_cod_ruta;
		end if

		foreach with hold
			select cod_cobertura
			  into _cod_cobertura
			  from emipocob
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad
			 order by no_poliza,no_unidad,cod_cobertura

			let _valor_flota = null;

			select valor_flota
			  into _valor_flota
			  from parautflot
			 where tipo_valor = "cod_cobertura"
			   and valor_auto = _cod_cobertura;

			if _valor_flota is not null and TRIM(_valor_flota) <> "" then

				-----Cobertura
				select *
				  from emipocob
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad
				   and cod_cobertura = _cod_cobertura
				  into temp tmp_ttco;

				update tmp_ttco
				   set cod_cobertura = _valor_flota;

				insert into emipocob
				select * 
				  from tmp_ttco;

				drop table tmp_ttco;

				update emicobde
				   set cod_cobertura = _valor_flota
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad
				   and cod_cobertura = _cod_cobertura;

				update emicobre
				   set cod_cobertura = _valor_flota
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad
				   and cod_cobertura = _cod_cobertura;

				delete from emipocob
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad
				   and cod_cobertura = _cod_cobertura;

				-----Cobertura Endoso
				select *
				  from endedcob
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad
				   and cod_cobertura = _cod_cobertura
				  into temp tmp_ttco;

				update tmp_ttco
				   set cod_cobertura = _valor_flota;

				insert into endedcob
				select * 
				  from tmp_ttco;

				drop table tmp_ttco;

				update endcobde
				   set cod_cobertura = _valor_flota
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad
				   and cod_cobertura = _cod_cobertura;

				update endcobre
				   set cod_cobertura = _valor_flota
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad
				   and cod_cobertura = _cod_cobertura;

				delete from endedcob
				 where no_poliza     = _no_poliza
				   and no_unidad     = _no_unidad
				   and cod_cobertura = _cod_cobertura;
			else
				rollback work;
				DROP TABLE tmp_emireaco;
				DROP TABLE tmp_emifafac;
				DROP TABLE tmp_recreafa;
				DROP TABLE tmp_cobredet;
				DROP TABLE tmp_emiglofa;
				return -1, "cod_cobertura",_cod_cobertura;
			end if
		end foreach

		foreach with hold
			select cod_cober_reas, 
				   no_cambio, 
				   orden, 
				   cod_contrato, 
				   porc_partic_suma, 
				   porc_partic_prima
			  into _cod_cober_reas, 
				   _no_cambio, 
				   _orden, 
				   _cod_contrato, 
				   _porc_partic_suma, 
				   _porc_partic_prima 
			  from emireaco
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad

			let _valor_flota = null;

			select valor_flota
			  into _valor_flota
			  from parautflot
			 where tipo_valor = "cod_cober_reas"
			   and valor_auto = _cod_cober_reas;

			if _valor_flota is not null and TRIM(_valor_flota) <> "" then
				insert into tmp_emireaco 
				   values (	_no_poliza,
							_no_unidad,
							_no_cambio,
							_valor_flota,
							_orden,
							_cod_contrato,
							_porc_partic_suma,
							_porc_partic_prima);

				delete from emireaco 
				 where no_poliza = _no_poliza
				   and no_unidad = _no_unidad
				   and no_cambio = _no_cambio
				   and cod_cober_reas = _cod_cober_reas
				   and orden = _orden;

			else
				rollback work;
				DROP TABLE tmp_emireaco;
				DROP TABLE tmp_emifafac;
				DROP TABLE tmp_recreafa;
				DROP TABLE tmp_cobredet;
				DROP TABLE tmp_emiglofa;
				return -1, "emireaco cod_cober_reas",_cod_cober_reas;
			end if
		end foreach

		foreach with hold
			select cod_cober_reas, no_cambio
			  into _cod_cober_reas, _no_cambio 
			  from emireama
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad

			let _valor_flota = null;

			select valor_flota
			  into _valor_flota
			  from parautflot
			 where tipo_valor = "cod_cober_reas"
			   and valor_auto = _cod_cober_reas;

			if _valor_flota is not null and TRIM(_valor_flota) <> "" then
				update emireama
				   set cod_cober_reas = _valor_flota
				 where no_poliza = _no_poliza
			       and no_unidad = _no_unidad
				   and no_cambio = _no_cambio
				   and cod_cober_reas = _cod_cober_reas;
			else
				rollback work;
				DROP TABLE tmp_emireaco;
				DROP TABLE tmp_emifafac;
				DROP TABLE tmp_recreafa;
				DROP TABLE tmp_cobredet;
				DROP TABLE tmp_emiglofa;
				return -1, "emireama cod_cober_reas",_cod_cober_reas;
			end if
		end foreach

		insert into emireaco(
			no_poliza,        
			no_unidad,        
			no_cambio,        
			cod_cober_reas,   
			orden,            
			cod_contrato,     
			porc_partic_suma, 
			porc_partic_prima)
		select no_poliza,        
				no_unidad,        
				no_cambio,        
				cod_cober_reas,   
				orden,            
				cod_contrato,     
				porc_partic_suma, 
				porc_partic_prima
		  from tmp_emireaco
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;     

		foreach with hold
			select cod_cober_reas, 
				   no_endoso, 
				   orden, 
				   cod_contrato, 
				   cod_coasegur,
				   porc_partic_reas,
				   porc_comis_fac,  
				   porc_impuesto,   
				   suma_asegurada,  
				   prima,           
				   impreso,         
				   fecha_impresion, 
				   no_cesion,       
				   subir_bo,        
				   monto_comision,  
				   monto_impuesto  
			  into _cod_cober_reas,
				   _no_endoso, 
				   _orden, 
				   _cod_contrato, 
				   _cod_coasegur,
				   _porc_partic_reas,
				   _porc_comis_fac,  
				   _porc_impuesto,   
				   _suma_asegurada,  
				   _prima,           
				   _impreso,         
				   _fecha_impresion, 
				   _no_cesion,       
				   _subir_bo,        
				   _monto_comision,  
				   _monto_impuesto  
			  from emifafac
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad

			let _valor_flota = null;

			select valor_flota
			  into _valor_flota
			  from parautflot
			 where tipo_valor = "cod_cober_reas"
			   and valor_auto = _cod_cober_reas;

			if _valor_flota is not null and TRIM(_valor_flota) <> "" then
				insert into tmp_emifafac 
				values(	_no_poliza,
						_no_endoso, 
						_no_unidad,
						_valor_flota,
						_orden, 
						_cod_contrato, 
						_cod_coasegur,
						_porc_partic_reas,
						_porc_comis_fac,  
						_porc_impuesto,   
						_suma_asegurada,  
						_prima,           
						_impreso,         
						_fecha_impresion, 
						_no_cesion,       
						_subir_bo,        
						_monto_comision,  
						_monto_impuesto);

					delete from emifafac 
					 where no_poliza = _no_poliza
					   and no_endoso = _no_endoso
					   and no_unidad = _no_unidad
					   and cod_cober_reas = _cod_cober_reas
					   and orden = _orden
					   and cod_contrato = _cod_contrato
					   and cod_coasegur = _cod_coasegur;
			else
				rollback work;
				DROP TABLE tmp_emireaco;
				DROP TABLE tmp_emifafac;
				DROP TABLE tmp_recreafa;
				DROP TABLE tmp_cobredet;
				DROP TABLE tmp_emiglofa;
				return -1, "emifafac cod_cober_reas",_cod_cober_reas;
			end if
		end foreach
	  
		foreach with hold
			select cod_ruta,
				   cod_cober_reas,
				   no_endoso,
				   orden
			  into _cod_ruta,
				   _cod_cober_reas,
				   _no_endoso,
				   _orden
			  from emifacon
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad

			let _valor_flota = null;

			if _cod_ruta is null or trim(_cod_ruta) = "" then
				continue foreach;
			end if

			select valor_flota
			  into _valor_flota
			  from parautflot
			 where tipo_valor = "cod_ruta"
			   and valor_auto = _cod_ruta;

			if _valor_flota is not null and TRIM(_valor_flota) <> "" then
				update emifacon
			       set cod_ruta = _valor_flota
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
			       and no_unidad = _no_unidad
				   and cod_cober_reas = _cod_cober_reas
				   and orden = _orden;
			else
				rollback work;
				DROP TABLE tmp_emireaco;
				DROP TABLE tmp_emifafac;
				DROP TABLE tmp_recreafa;
				DROP TABLE tmp_cobredet;
				DROP TABLE tmp_emiglofa;
				return -1, "emifacon cod_ruta", _cod_ruta;
			end if
		end foreach

		foreach with hold
			select cod_cober_reas, no_endoso, orden
			  into _cod_cober_reas, _no_endoso, _orden
			  from emifacon
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad

			let _valor_flota = null;

			select valor_flota
			  into _valor_flota
			  from parautflot
			 where tipo_valor = "cod_cober_reas"
			   and valor_auto = _cod_cober_reas;

			if _valor_flota is not null and TRIM(_valor_flota) <> "" then
				update emifacon
				   set cod_cober_reas = _valor_flota
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso
				   and no_unidad = _no_unidad
				   and cod_cober_reas = _cod_cober_reas
				   and orden = _orden;
			else
				rollback work;
				DROP TABLE tmp_emireaco;
				DROP TABLE tmp_emifafac;
				DROP TABLE tmp_recreafa;
				DROP TABLE tmp_cobredet;
				DROP TABLE tmp_emiglofa;
				return -1, "emifacon cod_cober_reas", _cod_cober_reas;
			end if
		end foreach

		insert into emifafac(
	         no_poliza,       
			 no_endoso,       
			 no_unidad,       
			 cod_cober_reas,  
			 orden,           
			 cod_contrato,    
			 cod_coasegur,    
			 porc_partic_reas,
			 porc_comis_fac,  
			 porc_impuesto,   
			 suma_asegurada,  
			 prima,           
			 impreso,         
			 fecha_impresion, 
			 no_cesion,       
			 subir_bo,        
			 monto_comision,  
			 monto_impuesto)
		select  no_poliza,        
				no_endoso,       
				no_unidad,       
				cod_cober_reas,  
				orden,           
				cod_contrato,    
				cod_coasegur,    
				porc_partic_reas,
				porc_comis_fac,  
				porc_impuesto,   
				suma_asegurada,  
				prima,           
				impreso,         
				fecha_impresion, 
				no_cesion,       
				subir_bo,        
				monto_comision,  
				monto_impuesto  
		  from tmp_emifafac
		 where no_poliza = _no_poliza
		   and no_unidad = _no_unidad;
	
		-- Reclamos
		foreach with hold
			select no_reclamo
			  into _no_reclamo
			  from recrcmae
			 where no_poliza = _no_poliza
			   and no_unidad = _no_unidad

			foreach with hold
				select no_reclamo,
					   orden,
					   cod_contrato,
					   cod_coasegur,
					   porc_partic_reas,
					   cod_cober_reas
				  into _no_reclamo,
					   _orden,
					   _cod_contrato,
					   _cod_coasegur,
					   _porc_partic_reas,
					   _cod_cober_reas
				  from recreafa
				 where no_reclamo = _no_reclamo

				let _valor_flota = null;

				select valor_flota
				  into _valor_flota
				  from parautflot
				 where tipo_valor = "cod_cober_reas"
				   and valor_auto = _cod_cober_reas;

				if _valor_flota is not null and TRIM(_valor_flota) <> "" then
					update recreafa
					   set cod_cober_reas = _valor_flota
					 where no_reclamo = _no_reclamo
					   and orden = _orden
					   and cod_contrato = _cod_contrato
					   and cod_cober_reas = _cod_cober_reas;
				else
					rollback work;
					DROP TABLE tmp_emireaco;
					DROP TABLE tmp_emifafac;
					DROP TABLE tmp_recreafa;
					DROP TABLE tmp_cobredet;
					DROP TABLE tmp_emiglofa;
					return -1, "recreafa cod_cober_reas",_cod_cober_reas;
				end if
			end foreach


			foreach with hold
				select cod_contrato,
					   cod_cober_reas,
					   orden
				  into _cod_contrato,
					   _cod_cober_reas,
					   _orden
				  from recreaco
				 where no_reclamo = _no_reclamo

				let _valor_flota = null;

				select valor_flota
				  into _valor_flota
				  from parautflot
				 where tipo_valor = "cod_cober_reas"
				   and valor_auto = _cod_cober_reas;

				if _valor_flota is not null and TRIM(_valor_flota) <> "" then
					update recreaco
					   set cod_cober_reas = _valor_flota
					 where no_reclamo     = _no_reclamo
					   and orden          = _orden
					   and cod_cober_reas = _cod_cober_reas;
				else
					rollback work;
					DROP TABLE tmp_emireaco;
					DROP TABLE tmp_emifafac;
					DROP TABLE tmp_recreafa;
					DROP TABLE tmp_cobredet;
					DROP TABLE tmp_emiglofa;
					return -1, "recreaco cod_cober_reas", _cod_cober_reas;
				end if
			end foreach

			foreach with hold
				select cobredet.no_remesa,       
					   cobredet.renglon,        
					   cobredet.cod_compania,    
					   cobredet.cod_sucursal,    
					   cobredet.no_poliza,       
					   cobredet.no_unidad,       
					   cobredet.no_tranrec,      
					   cobredet.cod_recibi_de,   
					   cobredet.no_reclamo,      
					   cobredet.cod_cobertura,   
					   cobredet.no_recibo,       
					   cobredet.doc_remesa,      
					   cobredet.tipo_mov,        
					   cobredet.monto,           
					   cobredet.prima_neta,      
					   cobredet.impuesto,        
					   cobredet.monto_descontado,
					   cobredet.comis_desc,      
					   cobredet.desc_remesa,     
					   cobredet.saldo,           
					   cobredet.periodo,         
					   cobredet.fecha,           
					   cobredet.actualizado,     
					   cobredet.cod_agente,      
					   cobredet.cod_auxiliar,    
					   cobredet.sac_asientos,    
					   cobredet.subir_bo,        
					   cobredet.flag_web_corr,   
					   cobredet.no_recibo2,      
					   cobredet.gastos_manejo   
				  into _no_remesa,       
					   _renglon,        
					   _cod_compania,    
					   _cod_sucursal,    
					   _no_poliza,       
					   _no_unidad,       
					   _no_tranrec,      
					   _cod_recibi_de,   
					   _no_reclamo,      
					   _cod_cobertura,   
					   _no_recibo,       
					   _doc_remesa,      
					   _tipo_mov,        
					   _monto,           
					   _prima_neta,      
					   _impuesto,        
					   _monto_descontado,
					   _comis_desc,      
					   _desc_remesa,     
					   _saldo,           
					   _periodo,         
					   _fecha,           
					   _actualizado,     
					   _cod_agente,      
					   _cod_auxiliar,    
					   _sac_asientos,    
					   _subir_bo,        
					   _flag_web_corr,   
					   _no_recibo2,      
					   _gastos_manejo   
				  from cobredet, recrccob
				 where cobredet.no_reclamo    = recrccob.no_reclamo
				   and cobredet.cod_cobertura = recrccob.cod_cobertura
				   and recrccob.no_reclamo    = _no_reclamo

				let _valor_flota = null;

				select valor_flota
				  into _valor_flota
				  from parautflot
				 where tipo_valor = "cod_cobertura"
				   and valor_auto = _cod_cobertura;

				if _valor_flota is not null and TRIM(_valor_flota) <> "" then
					insert into tmp_cobredet 
					   values (_no_remesa,       
							   _renglon,        
							   _cod_compania,    
							   _cod_sucursal,    
							   _no_poliza,       
							   _no_unidad,       
							   _no_tranrec,      
							   _cod_recibi_de,   
							   _no_reclamo,      
							   _valor_flota,   
							   _no_recibo,       
							   _doc_remesa,      
							   _tipo_mov,        
							   _monto,           
							   _prima_neta,      
							   _impuesto,        
							   _monto_descontado,
							   _comis_desc,      
							   _desc_remesa,     
							   _saldo,           
							   _periodo,         
							   _fecha,           
							   _actualizado,     
							   _cod_agente,      
							   _cod_auxiliar,    
							   _sac_asientos,    
							   _subir_bo,        
							   _flag_web_corr,   
							   _no_recibo2,      
							   _gastos_manejo);

					update rectrmae
					   set no_remesa = null
					  where no_tranrec = _no_tranrec;

					delete from cobredet 
					 where no_remesa = _no_remesa
					   and renglon   = _renglon;
				else
					rollback work;
					DROP TABLE tmp_emireaco;
					DROP TABLE tmp_emifafac;
					DROP TABLE tmp_recreafa;
					DROP TABLE tmp_cobredet;
					DROP TABLE tmp_emiglofa;
					return -1, "recreafa cod_cober_reas",_cod_cober_reas;
				end if
			end foreach

			foreach with hold
				select cod_cobertura
				  into _cod_cobertura
				  from recrccob
				 where no_reclamo = _no_reclamo

				if _cod_cobertura = "00566" then
					continue foreach;
				end if
				let _valor_flota = null;

				select valor_flota
				  into _valor_flota
				  from parautflot
				 where tipo_valor = "cod_cobertura"
				   and valor_auto = _cod_cobertura;

				if _valor_flota is not null and TRIM(_valor_flota) <> "" then
					update recrccob
					   set cod_cobertura = _valor_flota
					 where no_reclamo    = _no_reclamo
					   and cod_cobertura = _cod_cobertura;
				else
					rollback work;
					DROP TABLE tmp_emireaco;
					DROP TABLE tmp_emifafac;
					DROP TABLE tmp_recreafa;
					DROP TABLE tmp_cobredet;
					DROP TABLE tmp_emiglofa;
					return -1, "recreaco cod_cobertura", _cod_cobertura;
				end if
			end foreach

			foreach with hold
				select no_tranrec
				  into _no_tranrec
				  from rectrmae
				 where no_reclamo = _no_reclamo

				foreach with hold
					select no_tranrec, cod_cobertura
					  into _no_tranrec, _cod_cobertura
					  from rectrcob
					 where no_tranrec = _no_tranrec

					if _cod_cobertura = "00566" then
						continue foreach;
					end if
					
					let _valor_flota = null;

					select valor_flota
					  into _valor_flota
					  from parautflot
					 where tipo_valor = "cod_cobertura"
					   and valor_auto = _cod_cobertura;

					if _valor_flota is not null and TRIM(_valor_flota) <> "" then
						update rectrcob
						   set cod_cobertura = _valor_flota
						 where no_tranrec = _no_tranrec
						   and cod_cobertura = _cod_cobertura;
					else
						rollback work;
						DROP TABLE tmp_emireaco;
						DROP TABLE tmp_emifafac;
						DROP TABLE tmp_recreafa;
						DROP TABLE tmp_cobredet;
						DROP TABLE tmp_emiglofa;
						return -1, "rectrcob cod_cobertura", _cod_cobertura;
					end if
				end foreach

				foreach with hold
					select no_tranrec,
						   orden,
						   cod_contrato,
						   cod_cober_reas
					  into _no_tranrec,
						   _orden,
						   _cod_contrato,
						   _cod_cober_reas
					  from rectrrea
					 where no_tranrec = _no_tranrec

					let _valor_flota = null;

					select valor_flota
					  into _valor_flota
					  from parautflot
					 where tipo_valor = "cod_cober_reas"
					   and valor_auto = _cod_cober_reas;

					if _valor_flota is not null and TRIM(_valor_flota) <> "" then
						update rectrrea
						   set cod_cober_reas = _valor_flota
						 where no_tranrec     = _no_tranrec
						   and orden          = _orden
						   and cod_cober_reas = _cod_cober_reas;
					else
						rollback work;
						DROP TABLE tmp_emireaco;
						DROP TABLE tmp_emifafac;
						DROP TABLE tmp_recreafa;
						DROP TABLE tmp_cobredet;
						DROP TABLE tmp_emiglofa;
						return -1, "rectrrea cod_cober_reas", _cod_cober_reas;
					end if
				end foreach

				foreach with hold
					select no_tranrec,
						   orden,
						   cod_coasegur,
						   cod_contrato,
						   cod_cober_reas
					  into _no_tranrec,
						   _orden,
						   _cod_coasegur,
						   _cod_contrato,
						   _cod_cober_reas
					  from rectrref
					 where no_tranrec = _no_tranrec

					let _valor_flota = null;

					select valor_flota
					  into _valor_flota
					  from parautflot
					 where tipo_valor = "cod_cober_reas"
					   and valor_auto = _cod_cober_reas;

					if _valor_flota is not null and TRIM(_valor_flota) <> "" then
						update rectrref
						   set cod_cober_reas = _valor_flota
						 where no_tranrec     = _no_tranrec
						   and orden          = _orden 
						   and cod_coasegur   = _cod_coasegur
						   and cod_cober_reas = _cod_cober_reas;
					else
						rollback work;
						DROP TABLE tmp_emireaco;
						DROP TABLE tmp_emifafac;
						DROP TABLE tmp_recreafa;
						DROP TABLE tmp_cobredet;
						DROP TABLE tmp_emiglofa;
						return -1, "rectrref cod_cober_reas", _cod_cober_reas;
					end if
				end foreach
			end foreach

			foreach with hold
				select no_remesa,       
					   renglon,        
					   cod_compania,    
					   cod_sucursal,    
					   no_poliza,       
					   no_unidad,       
					   no_tranrec,      
					   cod_recibi_de,   
					   cod_cobertura,   
					   no_recibo,       
					   doc_remesa,      
					   tipo_mov,        
					   monto,           
					   prima_neta,      
					   impuesto,        
					   monto_descontado,
					   comis_desc,      
					   desc_remesa,     
					   saldo,           
					   periodo,         
					   fecha,           
					   actualizado,     
					   cod_agente,      
					   cod_auxiliar,    
					   sac_asientos,    
					   subir_bo,        
					   flag_web_corr,   
					   no_recibo2,      
					   gastos_manejo   
				  into _no_remesa,       
					   _renglon,        
					   _cod_compania,    
					   _cod_sucursal,    
					   _no_poliza,       
					   _no_unidad,       
					   _no_tranrec,      
					   _cod_recibi_de,   
					   _cod_cobertura,   
					   _no_recibo,       
					   _doc_remesa,      
					   _tipo_mov,        
					   _monto,           
					   _prima_neta,      
					   _impuesto,        
					   _monto_descontado,
					   _comis_desc,      
					   _desc_remesa,     
					   _saldo,           
					   _periodo,         
					   _fecha,           
					   _actualizado,     
					   _cod_agente,      
					   _cod_auxiliar,    
					   _sac_asientos,    
					   _subir_bo,        
					   _flag_web_corr,   
					   _no_recibo2,      
					   _gastos_manejo   
				  from tmp_cobredet
				 where no_reclamo = _no_reclamo

				insert into cobredet(
					no_remesa,       
					renglon,        
					cod_compania,    
					cod_sucursal,    
					no_poliza,       
					no_unidad,       
					no_tranrec,      
					cod_recibi_de,   
					no_reclamo,      
					cod_cobertura,   
					no_recibo,       
					doc_remesa,      
					tipo_mov,        
					monto,           
					prima_neta,      
					impuesto,        
					monto_descontado,
					comis_desc,      
					desc_remesa,     
					saldo,           
					periodo,         
					fecha,           
					actualizado,     
					cod_agente,      
					cod_auxiliar,    
					sac_asientos,    
					subir_bo,        
					flag_web_corr,   
					no_recibo2,      
					gastos_manejo)
				values(   
					_no_remesa,       
					_renglon,        
					_cod_compania,    
					_cod_sucursal,    
					_no_poliza,       
					_no_unidad,       
					_no_tranrec,      
					_cod_recibi_de,   
					_no_reclamo,      
					_cod_cobertura,   
					_no_recibo,       
					_doc_remesa,      
					_tipo_mov,        
					_monto,           
					_prima_neta,      
					_impuesto,        
					_monto_descontado,
					_comis_desc,      
					_desc_remesa,     
					_saldo,           
					_periodo,         
					_fecha,           
					_actualizado,     
					_cod_agente,      
					_cod_auxiliar,    
					_sac_asientos,    
					_subir_bo,        
					_flag_web_corr,   
					_no_recibo2,      
					_gastos_manejo);

				update rectrmae
				  set no_remesa = _no_remesa
				 where no_tranrec = _no_tranrec;
			end foreach
		end foreach
	end foreach
end foreach   	  	
end

COMMIT WORK;

DROP TABLE tmp_emireaco;
DROP TABLE tmp_emifafac;
DROP TABLE tmp_recreafa;
DROP TABLE tmp_cobredet;
DROP TABLE tmp_emiglofa;

let _error_cod  = 0;
let _error_desc = "Proceso Completado ...";

return _error_cod, _error_desc,"";

end procedure;
