-- Datos comisiones adicionales Marsh-Semusa 2019 - detalle
-- Creado    : 20/02/2020 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A. execute procedure sp_pro588d('001','001','2019-12')
drop procedure sp_pro588d;
create procedure sp_pro588d(a_compania char(3),a_sucursal char(3), a_periodo char(7))
returning char(10)  as cod_agente,
		  char(50)  as nombre_agente,
		  char(50)  as nombre_compania,
		  char(100) as nombre_tabla,
		  dec(16,2) as prima_suscrita,
		  dec(5,2)  as porc_comis_adic,
		  dec(16,2) as com_adicional,
		  char(7)   as desde,
	 	  char(7)   as hasta,
		  char(3)   as cod_tipo;  		  

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _no_poliza       char(10);
define _no_endoso       char(10);
define _cod_agente      char(10);
define _cod_agente_anterior char(10);
define _no_documento    char(20);	   
define _prima_suscrita  dec(16,2);
define _prima_suscrita2 dec(16,2);
define _prima_fac       dec(16,2);
define _cnt             integer;
define _porc_coaseguro	dec(16,4);
define _cod_tipoprod    char(3);
define _cod_tipo        char(3);
define _cod_ramo        char(3);
define _cod_subramo     char(3);
define _porcentaje      dec(16,4);
define _unificar        smallint;
define _excluir         smallint;
define _tipo_agente     char(1);
define _cod_grupo       char(5);
define _fronting	    smallint;
define _cod_perpago     char(3);
define _meses           smallint;
define _valor           decimal(16,2);
define _fecha_desde 	date;
define _fecha_hasta 	date;
define _per_act         char(2);
define _anio_aa			smallint;
define _per_ini_aa      char(7);
define _per_fin_aa      char(7);
define _nueva_renov     char(1);
define _estatus_poliza  char(1);
define _nombre_clte     char(100); 
define _cod_cliente     char(10);
define _nombre_agente   char(50); 
define _estatus_desc    char(50);
define _nom_grupo       char(50);
define _vigencia_final 	date;
define _vigencia_inic 	date;
define _nombre_tabla    char(100);  
define _porc_comis_adic dec(5,2); 
define _com_adicional   dec(16,2);
define _nombre_compania	char(50);
define _flag		smallint;

drop table if exists temp_marsh2;	
CREATE TEMP TABLE temp_marsh2(	
no_documento        CHAR(20), 
cod_tipo            char(3),
cod_ramo            char(3),
cod_subramo         char(3),
prima_suscrita      DEC(16,2) default 0,
Porc_comision_adic  DEC(16,2) default 0,
comision_adicional  DEC(16,2) default 0
) WITH NO LOG;

Drop table if exists temp_marsh;	
CREATE TEMP TABLE temp_marsh(	
cod_agente		  CHAR(5),            
nombre_agente     CHAR(50),
no_poliza		  CHAR(10),	         
no_documento      CHAR(20), 
nombre_clte    	  CHAR(100), 
nom_grupo         CHAR(50),
cod_grupo  		  CHAR(5),
vigencia_inic     DATE, 
vigencia_final    DATE, 
estatus_desc      CHAR(50),
cod_tipoprod      CHAR(3),            
prima_suscrita    DEC(16,2) default 0, 
porc_partic		  DEC(5,2) default 0,	         
porc_comis		  DEC(5,2) default 0,	
porc_comis_adic	  DEC(5,2) default 0,	
porc_coaseguro	  DEC(5,2) default 0,
com_adicional     DEC(16,4) default 0,
nueva_renov       CHAR(1),   
cod_ramo          CHAR(3),  
cod_subramo       CHAR(3),
cod_tipo          CHAR(3),
seleccionado      smallint  default 0,
flag              smallint  default 0
) WITH NO LOG;

--set debug file to "sp_pro588.trc";
--trace on;
begin
on exception set _error, _error_isam, _error_desc
	return '','','',_error_desc,_error,0,0,'','','';
end exception

 
let _nombre_compania = sp_sis01(a_compania);
--*******************************
-- Manejo de periodo de comision
--*******************************
let a_periodo = '2019-12';
let _anio_aa        = a_periodo[1,4];		          -- 2019
let _per_ini_aa     = _anio_aa ||'-01';               -- 2019-01
let _per_fin_aa     = a_periodo;    				  -- 2019-01 hasta 12

-- Fechas del Periodo Actual 2019
let _fecha_desde = MDY(1,1,a_periodo[1,4]);
let _fecha_hasta = sp_sis36(a_periodo); 

--***********************************
-- Prima Suscrita 2019 Anio Actual --
--***********************************
let _prima_suscrita	 = 0;
let _porc_comis_adic = 0;
let _com_adicional   = 0;
let _cod_tipo        = null;


let _flag = 0; 
foreach
	select a.no_endoso,
		   a.no_documento,
		   a.no_poliza,
		   a.prima_suscrita
	  into _no_endoso,
		   _no_documento,
           _no_poliza,		   
		   _prima_suscrita		   
	  from endedmae a, endmoage b, emipomae p
   	 where a.no_poliza = b.no_poliza
	   and a.no_endoso = b.no_endoso
	   and a.no_poliza = p.no_poliza
	   and b.cod_agente in ('01814','01853','00270')  -- Marsh SEMUSA	   
	   and a.actualizado = 1 --and p.cod_ramo in ('002','020','023','001')
	   and a.periodo between _per_ini_aa and _per_fin_aa	   
	--   and p.estatus_poliza  <> 2	   
	  let _flag = 0;  
	select count(*)
	  into _cnt
	  from somos_marsh					--Tabla para excluir polizas segun el requerimiento.
	 where no_documento = _no_documento;
		 
	if _cnt is null then
	   let _cnt = 0;
	end if	 
	
	if _cnt > 0 and _flag = 0 then  -- Excluir SOMOS MARSH
	   --continue foreach;
	   let _flag = 1;  
	end if			     	
	
	select cod_ramo, 
		   cod_subramo, 
		   cod_tipoprod, 
		   cod_grupo, 
		   fronting, 
		   nueva_renov, 
		   cod_contratante, 
		   vigencia_inic, 
		   vigencia_final, 
		   estatus_poliza,
		   cod_perpago
     into _cod_ramo, 
		  _cod_subramo, 
		  _cod_tipoprod, 
		  _cod_grupo, 
		  _fronting, 
		  _nueva_renov, 
		  _cod_cliente, 
		  _vigencia_inic, 
		  _vigencia_final, 
		  _estatus_poliza,
		  _cod_perpago
	 from emipomae
	where no_poliza = _no_poliza;	 	 
	  
	if _cod_grupo in("00000","1000") and _flag = 0 then -- Excluir Estado
		--continue foreach;
		let _flag = 2; 
	end if	
	
 
	if _fronting is null then
		let _fronting = 0;
	end if	 
	if _fronting = 1 and _flag = 0 then  -- Excluir Fronting
	   --continue foreach;
	   let _flag = 3;  
	end if


	if _cod_ramo = '017' and _cod_subramo = '002' then  -- Se excluye casco subramo aereo.
		continue foreach;
	end if
	
	if _cod_ramo = '019' then  -- Se excluye ramo vida individual0
		continue foreach;
	end if
	
	if _cod_ramo = '022' then  -- Se excluye ramo equipo pesado *** por confirmar ****
		continue foreach;
	end if		
	
	if _cod_ramo = '008' and _cod_subramo = '009' then  -- Se excluye Fianzas del subramo fidelidad.
		continue foreach;
	end if
	if ((_cod_ramo = '001' and _cod_subramo = '006') or (_cod_ramo = '003' and _cod_subramo = '006')) and _flag = 0  then  -- Se excluye Zona L.,France F. y Cocosolito.
		--continue foreach;
		let _flag = 4; 
	end if
	

	if _cod_ramo in('010','011','012','013','014') then  -- No tomar en cuenta Seguros técnicos
		continue foreach;
	end if		
		
	if _cod_ramo <> '018' then		
		select cod_tipo
		  into _cod_tipo
		  from somos_marsh_tabla 
		 where cod_ramo    = _cod_ramo; 					 		
	 else
		if _cod_ramo = '018' and _cod_subramo = '012' then  -- se asigna tipo 011 al COLECTIVO DE SALUD (018) Subramo (012)
			let _cod_tipo = '011';
		else
			let _cod_tipo = '012';
		end if							
	end if
	
	if _cod_ramo = '020' or _cod_ramo = '023' then  -- Se unifica Automovil 002 
		let _cod_ramo = '002';
	end if
		
	let _prima_fac      = 0;
		
	select sum(c.prima)
	  into _prima_fac
	  from emifacon c, reacomae r
	 where c.no_poliza = _no_poliza
	   and c.no_endoso = _no_endoso
	   and r.cod_contrato = c.cod_contrato
	   and r.tipo_contrato = 3;

	if _prima_fac is null then
		let _prima_fac = 0.00;
	end if
	if _prima_fac > 0 and _flag = 0 then
	   --continue foreach;     -- excluye facultativo
	   let _flag = 5; 
	end if
	



    --rehabilitada o cancelada 
    select count(*)
	  into _cnt
	  from endedmae
	 where no_poliza     = _no_poliza
	   and actualizado   = 1
	   and cod_endomov in ('003','002') --rehabilitacion y cancelacion 	
	   and fecha_emision between _fecha_desde and _fecha_hasta;
		  
	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt <> 0 and _flag = 0 then
		--continue foreach; 
          let _flag = 6; 		-- Excluye rehabilitada o cancelada
	end if	

		
	foreach
			select cod_agente,
				   porc_partic_agt
			  into _cod_agente_anterior,
				   _porcentaje
			  from endmoage
			 where no_poliza = _no_poliza
			   and no_endoso = _no_endoso
			   and cod_agente in ('01814','01853','00270')  -- marsh SEMUSA
			   
			let _prima_suscrita2 = 0.00;
			let _prima_suscrita2 = _prima_suscrita * _porcentaje /100;
			
			--********  Unificacion de Agente *******		
			call sp_che168(_cod_agente_anterior) returning _error,_cod_agente;		
			
			if _estatus_poliza = 1 then
				LET _estatus_desc = "VIGENTE";
			elif _estatus_poliza = 2 then
				LET _estatus_desc = "CANCELADA";
			elif _estatus_poliza = 3 then
				LET _estatus_desc = "VENCIDA";
			elif _estatus_poliza = 4 then
				LET _estatus_desc = "ANULADA";
			end if	
			
			select trim(nombre)
			  into _nom_grupo
			  from cligrupo
			 where cod_grupo = _cod_grupo;			
			 
			select trim(nombre)
			  into _nombre_clte
			  from cliclien
			 where cod_cliente = _cod_cliente;		 				 		 
			 
			select trim(nombre)
			  into _nombre_agente
			  from agtagent
			 where cod_agente = _cod_agente;		

			let _no_documento = _no_documento;			 
			if _flag in (0,6) then
			begin
			on exception in(-268,-239)
				update temp_marsh2
				   set prima_suscrita = prima_suscrita + _prima_suscrita2
				 where no_documento = _no_documento;		 
			end exception	
			
				insert into temp_marsh2(
				no_documento,
				cod_ramo,
				cod_subramo,
				prima_suscrita,
				porc_comision_adic,
				comision_adicional,
				cod_tipo)
				values (
				_no_documento,
				_cod_ramo,
				_cod_subramo,
				_prima_suscrita2,
				0,
				0,
				_cod_tipo);
			end
			end if
			
			let _no_documento = _no_documento;			 			
			begin
				on exception in(-268,-239)
					update temp_marsh
					   set prima_suscrita = prima_suscrita + _prima_suscrita2			   				   
					 where no_documento = _no_documento;
				end exception
				
				insert into temp_marsh(
					cod_agente, 
					no_documento,
					no_poliza,
					prima_suscrita,
					nombre_agente,
					nombre_clte,
					nom_grupo,
					cod_grupo,
					vigencia_inic,
					vigencia_final,
					estatus_desc,
					cod_tipoprod,
					nueva_renov,
					cod_ramo,
					cod_subramo,
					cod_tipo,flag )
				values (_cod_agente, 
					_no_documento, 
					_no_poliza,
					_prima_suscrita2,
					_nombre_agente,
					_nombre_clte,
					_nom_grupo,
					_cod_grupo,
					_vigencia_inic,
					_vigencia_final,
					_estatus_desc,
					_cod_tipoprod,
					_nueva_renov,
					_cod_ramo,
					_cod_subramo,
					_cod_tipo,_flag );
			end							
	end foreach
end foreach

let _com_adicional  = 0;
foreach
	select cod_tipo,
	       sum(prima_suscrita)			-- Prima Suscrita 2019
	  into _cod_tipo,      
	       _prima_suscrita
	  from temp_marsh2
	 group by cod_tipo
	 order by cod_tipo
	 
		select distinct descripcion,porc_comis
		  into _nombre_tabla,_porc_comis_adic
		  from somos_marsh_tabla 
		 where cod_tipo = _cod_tipo; 		 
		 
		if _porc_comis_adic is null then
			let _porc_comis_adic = 0;
		end if		 
		
		let _com_adicional  = _prima_suscrita * (_porc_comis_adic/ 100);
	 
return	_cod_agente,
		_nombre_agente,
		_nombre_compania,
		_nombre_tabla,
		_prima_suscrita,
		_porc_comis_adic,
		_com_adicional,
		_per_ini_aa,
		_per_fin_aa,
		_cod_tipo
		with resume;
end foreach
end
end procedure