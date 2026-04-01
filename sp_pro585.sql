-- Datos comisiones adicionales Marsh-Semusa
-- Creado    : 12/11/2018 - Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A. execute procedure sp_pro585('001','001','2018-06')
drop procedure sp_pro585;
create procedure sp_pro585(a_compania char(3),a_sucursal char(3), a_periodo char(7))
returning 
		char(10)  as cod_agente,
		char(50)  as nombre_agente,
		char(10)  as no_poliza,
		char(10)  as no_recibo,
		DATE      as fecha,
		char(20)  as no_documento,
		char(100) as nombre_clte,
		char(50)  as nom_grupo,
		char(5)	  as cod_grupo,
		DATE	  as vigencia_inic,
		DATE	  as vigencia_final,
		char(50)  as estatus_desc,
		char(3)	  as cod_tipoprod,
		dec(16,2) as prima_susc_n_aa,
		dec(16,2) as prima_susc_n_ap,
		dec(16,2) as prima_susc_r_aa,
		dec(16,2) as prima_susc_r_ap,
		dec(16,2) as prima_neta_cobrada,
		dec(5,2)  as porc_partic,
		dec(5,2)  as porc_comis,
		dec(5,2)  as porc_comis_adic,
		dec(16,4) as porc_coaseguro,
		dec(16,2) as com_adicional,
		char(1)	  as nueva_renov,
		char(3)	  as cod_ramo,
		char(3)	  as cod_subramo,
		dec(16,2) as tasa_com_adic,
		char(3)	  as cod_tipo,
		smallint  as seleccionado,
		CHAR(50)  as nombre_compania,
		char(50)  as nombre_ramo,
		char(7)   as desde,
		char(7)   as hasta,
		dec(16,2) as subtotal,
		dec(16,2) as total;

define _error			integer;
define _error_isam		integer;
define _error_desc		char(50);
define _no_poliza       char(10);
define _no_endoso, _cod_agente       char(10);
define _cod_agente_anterior       char(10);
define _no_documento    char(20);	   
define _prima_suscrita  dec(16,2);
define _prima_susc_aa dec(16,2);
define _prima_susc_ap dec(16,2);
define _cnt             integer;
define _porc_coaseguro	dec(16,4);
define _cod_tipoprod,_cod_ramo,_cod_subramo    char(3);
define _porc_partic_agt   dec(16,4);
DEFINE _nombre_compania	    CHAR(50);
DEFINE _fecha_desde 	    DATE;
DEFINE _fecha_hasta 	    DATE;
define _per_ini_aa          char(7);
define _per_fin_aa          char(7);
define _per_ini_ap          char(7);
define _per_fin_ap          char(7);
define _per_act             char(2);
define _anio_aa			    smallint;
define _anio_ap			    smallint;
define _fronting		    smallint;
define _pagada		        smallint;
define _cod_grupo           char(5);
define _nueva_renov         char(1);
define _prima_neta_cobrada  dec(16,2);
define _porc_partic         dec(5,2); 
define _estatus_poliza      char(1);
define _nombre_clte         char(100); 
define _cod_cliente         char(10);
define _nombre_agente       char(50); 
define _no_recibo           char(10); 
define _estatus_desc        char(50);
define _nom_grupo           char(50);
define _vigencia_final 		DATE;
define _vigencia_inic 		DATE;
define _porc_comis          dec(5,2); 
define _porc_comis_adic      dec(5,2); 
define _fecha               DATE;     
define _no_remesa           char(10);
define _renglon             smallint;
define _seleccionado        smallint;
DEFINE _tipo_mov            CHAR(1);  
DEFINE _monto               DEC(16,2);
DEFINE _prima               DEC(16,2);
DEFINE v_saldo              DEC(16,2);
DEFINE v_por_vencer         DEC(16,2);
DEFINE v_exigible           DEC(16,2);
DEFINE v_corriente          DEC(16,2);
DEFINE v_monto_30           DEC(16,2);
DEFINE v_monto_60           DEC(16,2);
define v_monto_90           DEC(16,2);
define _cod_coasegur	    char(3);
define _tasa                dec(16,2); 
define _com_adicional       dec(16,2);
define _prima_susc_N_aa     dec(16,2);
define _prima_susc_N_ap     dec(16,2);
define _prima_susc_R_aa     dec(16,2);
define _prima_susc_R_ap     dec(16,2);
define _total_susc_N_aa     dec(16,2);
define _total_susc_N_ap     dec(16,2);
define _total_susc_R_aa     dec(16,2);
define _total_susc_R_ap     dec(16,2);
define _cod_tipo            char(3);
define _nombre_ramo         char(50); 
define _meses               smallint;
define _valor               decimal(16,2);
define _cod_perpago         char(3);
DEFINE v_subtotal           DEC(16,2);
DEFINE v_subtotal_n         DEC(16,2);
DEFINE v_subtotal_r         DEC(16,2);
define v_total              DEC(16,2);


SET ISOLATION TO DIRTY READ;
-- SET DEBUG FILE TO "sp_pro585.trc";
-- TRACE ON;

return '','Consultar a IT','','','01/01/1900','','','','','01/01/1900','01/01/1900','','',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,'','','',0.00,'',0,'','','','',0,0;  -- HGIRON 05/03/2020 solicitud:AMORENO

begin
on exception set _error, _error_isam, _error_desc
	return '',_error_desc,'','','01/01/1900','','','','','01/01/1900','01/01/1900','','',0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,0.00,'','','',0.00,'',_error,'','','','',0,0;
end exception

drop table if exists temp_marsh2;	
CREATE TEMP TABLE temp_marsh2(	
no_documento        CHAR(20), 
nueva_renov         char(1),
prima_susc_N_aa     DEC(16,2) default 0,
prima_susc_N_ap     DEC(16,2) default 0,
prima_susc_R_aa     DEC(16,2) default 0, 
prima_susc_R_ap     DEC(16,2) default 0,
prima_neta_cobrada       DEC(16,2) default 0 
) WITH NO LOG;

drop table if exists temp_marsh;	
CREATE TEMP TABLE temp_marsh(	
cod_agente		  CHAR(5),            
nombre_agente     CHAR(50),
no_poliza		  CHAR(10),	         
no_recibo		  CHAR(10),	         
fecha			  DATE, 
no_documento      CHAR(20), 
nombre_clte    	  CHAR(100), 
nom_grupo         CHAR(50),
cod_grupo  		  CHAR(5),
vigencia_inic     DATE, 
vigencia_final    DATE, 
estatus_desc      CHAR(50),
cod_tipoprod      CHAR(3),            
prima_susc_N_aa     DEC(16,2) default 0, 
prima_susc_N_ap     DEC(16,2) default 0,
prima_susc_R_aa     DEC(16,2) default 0, 
prima_susc_R_ap     DEC(16,2) default 0,
prima_neta_cobrada     DEC(16,2) default 0,
porc_partic		  DEC(5,2) default 0,	         
porc_comis		  DEC(5,2) default 0,	
porc_comis_adic	  DEC(5,2) default 0,	
porc_coaseguro	  DEC(5,2) default 0,
com_adicional     DEC(16,4) default 0,
nueva_renov       CHAR(1),   
cod_ramo          CHAR(3),  
cod_subramo       CHAR(3),
tasa_com_adic     DEC(5,2) default 0,
cod_tipo          CHAR(3),
seleccionado      smallint  default 0
,PRIMARY KEY		( no_documento )
) WITH NO LOG;

let _prima_suscrita	= 0;
let _prima_neta_cobrada = 0;
let _porc_comis_adic = 0;
let _error_desc = '';
let _prima = 0;
let _nombre_ramo = '';
let _valor          = 0;

let _prima_susc_N_aa     = 0;
let _prima_susc_N_ap     = 0;
let _prima_susc_R_aa     = 0;
let _prima_susc_R_ap     = 0;
let v_por_vencer    	 = 0;
let v_exigible	    	 = 0;
let v_corriente	    	 = 0;
let v_monto_30	    	 = 0;
let v_monto_60	    	 = 0;
let v_monto_90	    	 = 0;
let v_saldo         	 = 0;
let _tasa                = 0;
let _com_adicional       = 0;
let _total_susc_N_aa     = 0;
let _total_susc_N_ap     = 0;
let _total_susc_R_aa     = 0;
let _total_susc_R_ap     = 0;
let _cod_tipo = '';
let v_subtotal_n         = 0;
let v_subtotal_r         = 0;
let v_subtotal           = 0;
let v_total              = 0;
  
let _nombre_compania = sp_sis01(a_compania);
--*******************************
-- Manejo de periodo de comision
--*******************************
if a_periodo < "2018-12" then
	let _per_act    = a_periodo[6,7];
elif a_periodo = "2018-12" then
	let _per_act    = '12';
else
	let _per_act    = a_periodo[6,7];
end if
let _anio_aa        = a_periodo[1,4];		  --2018
let _per_ini_aa     = _anio_aa ||'-01';       --2018-01
let _per_fin_aa     = _anio_aa || '-' || _per_act;    --2018-01 hasta 12

-- Periodo Pasado
let _anio_ap        = _anio_aa - 1;			  --2017
let _per_ini_ap     = _anio_ap ||'-01';       --2017-01
let _per_fin_ap     = _anio_ap || '-' || _per_act;    --2017-01 hasta 12

-- Fechas del Periodo Actual 2018
let _fecha_desde = MDY(1, 1, a_periodo[1,4]);
let _fecha_hasta = sp_sis36(a_periodo); 

select par_ase_lider
  into _cod_coasegur
  from parparam
 where cod_compania = a_compania;

--*******************************
-- Prima Suscrita 2018 Anio Actual -- 
--*******************************
foreach
	select a.no_documento,
		   p.nueva_renov
	  into _no_documento,
	       _nueva_renov
	  from endedmae a, endmoage b, emipomae p
   	 where a.no_poliza = b.no_poliza
	   and a.no_endoso = b.no_endoso
	   and a.no_poliza = p.no_poliza
	   and a.cod_endomov   = "011"
	   and b.cod_agente in ('01814','01853','00270')  -- marsh SEMUSA
	   and a.actualizado  = 1
	   and a.periodo between _per_ini_aa and _per_fin_aa			
	   and p.estatus_poliza  <> 2
	   and p.cod_ramo <> '018'	  
	 group by a.no_documento,p.nueva_renov		 	

	let _no_poliza = sp_sis21(_no_documento);	 
	   
	foreach
		select sum(a.prima_suscrita)
		  into _prima_suscrita
		  from endedmae a, emipomae p
		 where a.no_poliza = p.no_poliza
           and a.no_documento = _no_documento
		   and a.actualizado  = 1
		   and a.periodo between _per_ini_aa and _per_fin_aa				   		   				   		   
   		   
		select count(*)
		  into _cnt
		  from emifafac
		 where no_poliza = _no_poliza;
		 
		if _cnt is null then
		   let _cnt = 0;
		end if	 
		
		if _cnt > 0 then  -- Excluir Facultativo			
			select sum(a.prima)
			  into _prima_suscrita
			  from emifacon a, endedmae e, reacomae r
			 where a.no_poliza = e.no_poliza
			   and a.no_endoso = e.no_endoso
			   and a.cod_contrato = r.cod_contrato
			   and r.tipo_contrato in (1)			--Contrato Retencion
			   and e.actualizado = 1
			   and e.periodo  between _per_ini_aa and _per_fin_aa			
			   and e.no_documento = _no_documento;				   
		end if		   

		if _nueva_renov = "N" then
			let _prima_susc_N_aa     = _prima_suscrita;	
			let _prima_susc_R_aa     = 0;			
		else
			let _prima_susc_N_aa     = 0;	
			let _prima_susc_R_aa     = _prima_suscrita;				
		end if

		begin
		on exception in(-268,-239)
			update temp_marsh2
			   set prima_susc_N_aa = prima_susc_N_aa + _prima_susc_N_aa,
				   prima_susc_R_aa = prima_susc_R_aa + _prima_susc_R_aa
			 where no_documento = _no_documento;		 
		end exception			
			insert into temp_marsh2(no_documento, nueva_renov, prima_susc_N_aa, prima_susc_R_aa)
			values (_no_documento, _nueva_renov, _prima_susc_N_aa, _prima_susc_R_aa);
		end
	end foreach
end foreach
--**************************************
-- Prima Suscrita SALUD 2018 Anio Actual 
--**************************************
Foreach
	select c.no_documento
	  into _no_documento
	  from emipomae c, emipoagt e
	 where c.no_poliza = e.no_poliza	  
       and e.cod_agente in ('01814','01853','00270')  -- marsh SEMUSA
	   and c.actualizado   = 1
	   and c.nueva_renov   = "N"	   
	   and c.vigencia_inic between _fecha_desde and _fecha_hasta	   	   
	   and c.cod_ramo = '018'
	   and c.estatus_poliza  <> 2
	 group by c.no_documento
	 order by c.no_documento

	let _no_poliza = sp_sis21(_no_documento);
	select nueva_renov,
	       no_documento,
		   prima_suscrita,		   
		   cod_perpago
	  into _nueva_renov,
	       _no_documento,
		   _prima_suscrita,
		   _cod_perpago		   
	  from emipomae
	 where no_poliza = _no_poliza;
	 
	select count(*)
	  into _cnt
	  from emifafac
	 where no_poliza = _no_poliza;
	 
		if _cnt is null then
		   let _cnt = 0;
	   end if	 
	
		if _cnt > 0 then  -- Excluir Facultativo			
			select sum(a.prima)
			  into _prima_suscrita
			  from emifacon a, endedmae e, reacomae r
			 where a.no_poliza = e.no_poliza
			   and a.no_endoso = e.no_endoso
			   and a.cod_contrato = r.cod_contrato
			   and r.tipo_contrato in (1)
			   and e.actualizado = 1
			   and e.periodo  between _per_ini_aa and _per_fin_aa	
			   and e.no_documento = _no_documento;				   
		end if		   	 

	--Para salud, debe ser la prima anualizada
	select meses
	  into _meses
	  from cobperpa
	 where cod_perpago = _cod_perpago;

	let _valor = 0;
	if _cod_perpago = '001' then
		let _meses = 1;
	end if
	if _cod_perpago = '008' or _cod_perpago = '006' then	--Es anual o inmediata, ya esta el 100% de la prima
		let _meses = 12;
	end if	
	let _valor = 12 / _meses;
	let _prima_suscrita = _prima_suscrita * _valor;	

	insert into temp_marsh2(no_documento, nueva_renov, prima_susc_N_aa)
	values (_no_documento, _nueva_renov, _prima_suscrita);
end foreach
--********************************
-- Prima Suscrita  Anio Anterior - 
--********************************
foreach
	 select a.no_documento,
			p.nueva_renov
	   into _no_documento,
			_nueva_renov
		 from endedmae a, endmoage b,emipomae p
		where a.no_poliza = b.no_poliza
		  and a.no_endoso = b.no_endoso
		  and a.no_poliza     = p.no_poliza
		  and a.cod_endomov   = "011"
		  and b.cod_agente in ('01814','01853','00270')  -- marsh SEMUSA
		  and a.actualizado  = 1
		  and a.periodo between _per_ini_ap and _per_fin_ap			
		  and p.estatus_poliza  <> 2
		  and p.cod_ramo <> '018'	
		  group by a.no_documento,p.nueva_renov	
	  
	let _no_poliza = sp_sis21(_no_documento);
	  
	foreach
		select sum(a.prima_suscrita)
		  into _prima_suscrita
		  from endedmae a, emipomae p
		 where a.no_poliza = p.no_poliza
           and a.no_documento = _no_documento
		   and a.actualizado  = 1
		   and a.periodo between _per_ini_ap and _per_fin_ap		  
		   	   		   
		select count(*)
		  into _cnt
		  from emifafac
		 where no_poliza = _no_poliza;
		 
		    if _cnt is null then
			   let _cnt = 0;
		   end if	 
		
		    if _cnt > 0 then  -- Excluir Facultativo			
				select sum(a.prima)
				  into _prima_suscrita
				  from emifacon a, endedmae e, reacomae r
				 where a.no_poliza = e.no_poliza
				   and a.no_endoso = e.no_endoso
				   and a.cod_contrato = r.cod_contrato
				   and r.tipo_contrato in (1)
				   and e.actualizado = 1
				   and e.periodo  between _per_ini_ap and _per_fin_ap		  
                   and e.no_documento = _no_documento;				   
		    end if		   

		if _nueva_renov = "N" then
			let _prima_susc_N_ap     = _prima_suscrita;	
			let _prima_susc_R_ap     = 0;			
		else
			let _prima_susc_N_ap     = 0;	
			let _prima_susc_R_ap     = _prima_suscrita;				
		end if

		begin
		on exception in(-268,-239)
			update temp_marsh2
			   set prima_susc_N_ap = prima_susc_N_ap + _prima_susc_N_ap,
				   prima_susc_R_ap = prima_susc_R_ap + _prima_susc_R_ap
			 where no_documento = _no_documento;		 
		end exception			
			insert into temp_marsh2(no_documento, nueva_renov, prima_susc_N_ap, prima_susc_R_ap)
			values (_no_documento, _nueva_renov, _prima_susc_N_ap, _prima_susc_R_ap);
		end 
	end foreach
end foreach
--********************************
--********************************
foreach
	select no_documento,
	       sum(prima_susc_N_aa),			--   prima Nueva Suscrita Actual
	       sum(prima_susc_R_aa),			--   prima Renovada Suscrita Actual
	       sum(prima_susc_N_ap),			--   prima Nueva Suscrita Anio Pasado
	       sum(prima_susc_R_ap)			    --   prima Renovada Suscrita Anio Pasado
	  into _no_documento,
	       _total_susc_N_aa,
	       _total_susc_R_aa,
	       _total_susc_N_ap,
	       _total_susc_R_ap		
	  from temp_marsh2
	 group by no_documento
	 order by no_documento

	let _no_poliza = sp_sis21(_no_documento);

	 select cod_ramo, 
			cod_subramo, 
			cod_tipoprod, 
			cod_grupo, 
			fronting, 
			nueva_renov, 
			cod_contratante, 
			vigencia_inic, 
			vigencia_final, 
			estatus_poliza
      into _cod_ramo, 
			_cod_subramo, 
			_cod_tipoprod, 
			_cod_grupo, 
			_fronting, 
			_nueva_renov, 
			_cod_cliente, 
			_vigencia_inic, 
			_vigencia_final, 
			_estatus_poliza
	   from emipomae
	  where no_poliza = _no_poliza;

    if _cod_ramo = '001' and _cod_subramo = '006' then  -- Se excluye Zona L.,France F. 
		continue foreach;
	end if	 
	if _cod_grupo in('00000','1000') then  -- Grupo del estado no aplica
		continue foreach;
	end if	 	 
	
	if _nueva_renov = 'R' then
		if  _cod_ramo in ('018','016','004','013','014','008') then  -- Excluir en Conservacion los ramos de salud individual, colectivo, montaje, fianzas y car
			continue foreach;		
		end if	
		
		select pagada
		  into _pagada
		  from emiletra
		 where no_poliza = _no_poliza
		   and no_letra = 1;
		   
		if _pagada = 0 then        -- tomar en cuenta solo las del primer pago ASTANZIO
			continue foreach;
		end if		
	end if							 	
	
    -- Excluir rehabilitada o cancelada en el periodo 
   select count(*)
     into _cnt
     from endedmae
    where no_poliza     = _no_poliza
	  and actualizado   = 1
      and cod_endomov in ('003')  	-- Excluir de la rehabilitacion
      and fecha_emision >= _fecha_desde
	  and fecha_emision <= _fecha_hasta;
	  
	if _cnt is null then
		let _cnt = 0;
	end if
	if _cnt > 0 then      
		continue foreach;
	end if
    -- Excluir cambio y traspaso de corredor en el periodo	
	select count(*)
      into _cnt
      from endedmae a, endmoage b
     where a.no_poliza = b.no_poliza
       and a.no_endoso = b.no_endoso
       and a.actualizado   = 1
       and a.no_poliza     = _no_poliza
       and a.cod_endomov   in ('012','031')
       and a.fecha_emision >= _fecha_desde
       and a.fecha_emision <= _fecha_hasta
       and b.cod_agente not in ('01814','01853','00270');

	if _cnt is null then
		let _cnt = 0;
	end if
	
	if _cnt > 0 then      
		continue foreach;
	end if
	
	if _fronting is null then
		let _fronting = 0;
	end if	 
	if _fronting = 1 then  -- Excluir Fronting
		continue foreach;
	end if
	
    if _cod_ramo = '020' or _cod_ramo = '023' then  -- Se unifica Automovil 002
		let _cod_ramo = '002';
	end if		

	foreach
		select cod_agente,
			   porc_partic_agt
		  into _cod_agente_anterior,
			   _porc_partic_agt
		  from emipoagt
		 where no_poliza = _no_poliza		   
		   and cod_agente in ('01814','01853','00270')  -- marsh SEMUSA
		
		--******** Unificacion de Agente *******
		call sp_che168(_cod_agente_anterior) returning _error, _cod_agente;		
		
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
		 
		let _prima_susc_N_aa     = _porc_partic_agt * _total_susc_N_aa / 100;
		let _prima_susc_N_ap     = _porc_partic_agt * _total_susc_N_ap / 100;
		let _prima_susc_R_aa     = _porc_partic_agt * _total_susc_R_aa / 100;
		let _prima_susc_R_ap     = _porc_partic_agt * _total_susc_R_ap / 100;		 		
	
		begin
			on exception in(-268,-239)
				update temp_marsh
				   set prima_susc_N_aa = prima_susc_N_aa + _prima_susc_N_aa,
					   prima_susc_N_ap = prima_susc_N_ap + _prima_susc_N_ap,				   
					   prima_susc_R_aa = prima_susc_R_aa + _prima_susc_R_aa,
					   prima_susc_R_ap = prima_susc_R_ap + _prima_susc_R_ap				   				   
				 where no_documento = _no_documento;
			end exception
			
			insert into temp_marsh(cod_agente, no_documento,no_poliza,prima_susc_N_aa,prima_susc_R_aa, prima_susc_N_ap,prima_susc_R_ap, nombre_agente,nombre_clte,nom_grupo,cod_grupo,vigencia_inic,vigencia_final,estatus_desc,cod_tipoprod,prima_neta_cobrada,nueva_renov,cod_ramo,cod_subramo,seleccionado  )
			values (_cod_agente, _no_documento, _no_poliza,_prima_susc_N_aa,_prima_susc_R_aa, _prima_susc_N_ap,_prima_susc_R_ap, _nombre_agente,_nombre_clte,_nom_grupo,_cod_grupo,_vigencia_inic,_vigencia_final,_estatus_desc,_cod_tipoprod, 0,_nueva_renov,_cod_ramo,_cod_subramo,0 );
		end					
	end foreach
end foreach

--********************************************************
-- Prima Cobrada Neta de Polizas Renovadas/Nueva Año Actual
--********************************************************
--trace on;
foreach
	select cod_agente,
		   cod_tipoprod,
		   no_poliza,
		   no_documento,
		   cod_ramo
	  into _cod_agente,
           _cod_tipoprod,
		   _no_poliza,
		   _no_documento,
           _cod_ramo		   
	  from temp_marsh        	 

 	-- Morosidades Mayores a 90 Dias (No Se Incluyen)
	call sp_cob33(a_compania, a_sucursal, _no_documento, a_periodo, _fecha_hasta)
	     returning v_por_vencer,    
	               v_exigible,      
	               v_corriente,    
	               v_monto_30,      
	               v_monto_60,      
	               v_monto_90,
	               v_saldo;   
	
	if v_monto_90 > 0 then	 
		continue foreach;
	end if

	foreach
		select d.no_recibo,
			   d.fecha,				   
			   d.prima_neta,				  
			   c.porc_partic_agt
		  into _no_recibo,
			   _fecha,				   
			   _prima_neta_cobrada,				  
			   _porc_partic
		  from cobredet d, cobremae m, cobreagt c
		 where	d.no_remesa   = m.no_remesa
		   and d.no_remesa    = c.no_remesa
		   and d.renglon      = c.renglon			  
		   and d.actualizado  = 1
		   and d.tipo_mov     in ('P','N')
		   and d.fecha        >= _fecha_desde and d.fecha <= _fecha_hasta
		   and d.no_poliza     = _no_poliza
		   and m.tipo_remesa  in ('A', 'M', 'C')
		   and c.cod_agente   in ('01814','01853','00270')
		 order by d.fecha,d.no_recibo,d.no_poliza

			if _cod_tipoprod = "001" then	  -- Coaseguro Mayoritario, nuestra participacion.

				select porc_partic_coas
				  into _porc_coaseguro
				  from emicoama
				 where no_poliza    = _no_poliza
				   and cod_coasegur = '036';  -- ANCON

				if _porc_coaseguro is null then
					let _porc_coaseguro = 0.00;		          
				end if
				
				let _prima_neta_cobrada = _prima_neta_cobrada * (_porc_coaseguro / 100);
			end if
			
			let _prima_neta_cobrada = _prima_neta_cobrada * (_porc_partic / 100);					

			update temp_marsh
               set prima_neta_cobrada = prima_neta_cobrada + _prima_neta_cobrada,
				   porc_partic        = _porc_partic,				   				  
				   porc_comis_adic	  = 0,
				   com_adicional      = 0,		
				   no_recibo          = _no_recibo,
				   fecha              = _fecha
             where no_poliza          = _no_poliza;			 
	end foreach			
end foreach
--**************************************
-- Por Conservación de Cartera  2.1   **
--**************************************
foreach	  
 select cod_ramo,
		sum(prima_susc_R_aa),			--   prima Renovada Suscrita Actual
		sum(prima_susc_N_ap),			--   prima Nueva Suscrita Anio Pasado
		sum(prima_susc_R_ap),			--   prima Renovada Suscrita Anio Pasado
		sum(prima_neta_cobrada)			--   prima Cobrada Neta Anio Actual
   into _cod_ramo,
		_prima_susc_R_aa,
		_prima_susc_N_ap,
		_prima_susc_R_ap,	
		_prima_neta_cobrada
   from temp_marsh 
  where nueva_renov = 'R'  
  group by cod_ramo
  order by cod_ramo
  
	let _tasa = 0;
	let _tasa = (_prima_susc_R_aa/(_prima_susc_N_ap + _prima_susc_R_ap)) * 100;
  
	Let _porc_comis_adic = 0;	   
	let _seleccionado    = 0;
	let _com_adicional   = 0;
	let _cod_tipo        = '210';
	   
	-- Unificar Tabla de Rangos Comisión Marsh
    select a.porc_comis
	  into _porc_comis_adic
	  from prdmarsh1 a,prdmarsh0 b
	 where periodo[1,4]  = a_periodo[1,4] 
	   and a.cod_tipo = _cod_tipo
	   and a.nueva_renov = 'R'
	   and b.cod_ramo = _cod_ramo
       and a.cod_tipo = b.cod_tipo
	   and round(_tasa,2) between rango_inicial and rango_final; 		   
	   
	    if _porc_comis_adic is null then
	       Let _porc_comis_adic = 0;	   
		   let _com_adicional   = 0;	   		   
		   let _seleccionado    = 0;
        else		   
		   let _seleccionado = 1;	  
	    end if	
	
		let _com_adicional  = _prima_neta_cobrada * (_porc_comis_adic/ 100);
	    let v_subtotal_r    = v_subtotal_r + _com_adicional;
	    let v_total         = v_total + _com_adicional;		
		
	update temp_marsh
	   set porc_comis_adic = _porc_comis_adic,
		   com_adicional   = _com_adicional,
		   seleccionado    = _seleccionado,	
           tasa_com_adic   = _tasa,
           cod_tipo        = _cod_tipo		   
	 where nueva_renov     = 'R'
	   and cod_ramo        = _cod_ramo;					      
end foreach
--************************************************************
-- Por Produccion Nueva         2.2.1, 2.2.2, 2.2.4 y 2.2.5 **
--************************************************************
-- TRACE ON;
foreach	  
 select cod_ramo,
	    sum(prima_susc_N_aa),
		sum(prima_neta_cobrada)			--   prima Cobrada Nueva		
   into _cod_ramo,
		_prima_susc_N_aa,
		_prima_neta_cobrada
   from temp_marsh 
  where nueva_renov = 'N' and cod_ramo not in ('018')
  group by cod_ramo
  order by cod_ramo
  
	   Let _porc_comis_adic = 0;	   
	   let _seleccionado = 0;
	   let _com_adicional = 0;	   
	   
	   select cod_tipo
	     into _cod_tipo
		 from prdmarsh0 
		where cod_ramo in (_cod_ramo) 
		  and cod_tipo not in ('210');   
	   
	-- Unificar Tabla de Rangos Comisión Marsh
    select a.porc_comis
	  into _porc_comis_adic
	  from prdmarsh1 a,prdmarsh0 b
	 where periodo[1,4]  = a_periodo[1,4] 
	   and a.nueva_renov = 'N'
	   and a.cod_tipo = _cod_tipo
	   and b.cod_ramo = _cod_ramo
       and a.cod_tipo = b.cod_tipo
	   and round(_prima_susc_N_aa,2) between rango_inicial and rango_final; 
	   
	    if _porc_comis_adic is null then
	       Let _porc_comis_adic = 0;	   
		   let _com_adicional = 0;	   
		   let _seleccionado = 0;
        else		   
		   let _seleccionado = 1;	  
	    end if	
	
		let _com_adicional  = _prima_neta_cobrada * (_porc_comis_adic/ 100);
	    let v_subtotal_n    = v_subtotal_n + _com_adicional;
	    let v_total         = v_total + _com_adicional;				
		
	update temp_marsh
	   set porc_comis_adic = _porc_comis_adic,
		   com_adicional   = _com_adicional,
		   seleccionado    = _seleccionado,	
           tasa_com_adic   = 0,
           cod_tipo        = _cod_tipo		   
	 where nueva_renov     = 'N'
	   and cod_ramo        = _cod_ramo;					      
end foreach
--********************************************************************
-- Por Produccion Nueva   SALUD y COLECTIVO      2.2.2 y 2.2.3      **
--********************************************************************
--TRACE ON;
foreach	  
	select cod_ramo,
	       cod_subramo,
	       sum(prima_susc_N_aa),
		   sum(prima_neta_cobrada)					
	  into _cod_ramo,_cod_subramo,
	       _prima_susc_N_aa,
		   _prima_neta_cobrada
	  from temp_marsh 
	 where nueva_renov = 'N' and cod_ramo in ('018')
	 group by cod_ramo,cod_subramo
	 order by cod_ramo,cod_subramo  
  
	Let _porc_comis_adic = 0;	   
	let _seleccionado    = 0;
	let _com_adicional   = 0;
	   
	if _cod_subramo in ('012') then
	    let _cod_tipo = '223';    -- SALUD COLECTIVO
	else
	    let _cod_tipo = '222';    -- SALUD INDIVIDUAL
	end if
	   
	-- Unificar Tabla de Rangos Comisión Marsh
    select a.porc_comis
	  into _porc_comis_adic
	  from prdmarsh1 a,prdmarsh0 b
	 where periodo[1,4]  = a_periodo[1,4] 
	   and a.nueva_renov = 'N'
	   and a.cod_tipo = _cod_tipo
	   and b.cod_ramo = _cod_ramo
       and a.cod_tipo = b.cod_tipo
	   and round(_prima_susc_N_aa,2) between rango_inicial and rango_final; 		   
	   
	if _porc_comis_adic is null then
	       Let _porc_comis_adic = 0;	   
		   let _com_adicional = 0;	   
		   let _seleccionado = 0;
    else		   
		   let _seleccionado = 1;	  
	end if	
	
	let _com_adicional  = _prima_neta_cobrada * (_porc_comis_adic/ 100);
	let v_subtotal_n    = v_subtotal_n + _com_adicional;
	let v_total         = v_total + _com_adicional;
		
	update temp_marsh
	   set porc_comis_adic	= _porc_comis_adic,
		   com_adicional = _com_adicional,
		   seleccionado = _seleccionado,	
           tasa_com_adic = 1,
           cod_tipo = _cod_tipo		   
	 where nueva_renov  = 'N'
	   and cod_ramo = _cod_ramo
	   and cod_subramo = _cod_subramo;					      
end foreach

foreach
	select cod_agente,
			nombre_agente,
			no_poliza,
			no_recibo,
			fecha,
			no_documento,
			nombre_clte,
			nom_grupo,
			cod_grupo,
			vigencia_inic,
			vigencia_final,
			estatus_desc,
			cod_tipoprod,
			prima_susc_n_aa,
			prima_susc_n_ap,
			prima_susc_r_aa,
			prima_susc_r_ap,
			prima_neta_cobrada,
			porc_partic,
			porc_comis,
			porc_comis_adic,
			porc_coaseguro,
			com_adicional,
			nueva_renov,
			cod_ramo,
			cod_subramo,
			tasa_com_adic,
			cod_tipo,
			seleccionado
	  into _cod_agente,
			_nombre_agente,
			_no_poliza,
			_no_recibo,
			_fecha,
			_no_documento,
			_nombre_clte,
			_nom_grupo,
			_cod_grupo,
			_vigencia_inic,
			_vigencia_final,
			_estatus_desc,
			_cod_tipoprod,
			_prima_susc_n_aa,
			_prima_susc_n_ap,
			_prima_susc_r_aa,
			_prima_susc_r_ap,
			_prima_neta_cobrada,
			_porc_partic,
			_porc_comis,
			_porc_comis_adic,
			_porc_coaseguro,
			_com_adicional,
			_nueva_renov,
			_cod_ramo,
			_cod_subramo,
			_tasa,
			_cod_tipo,
			_seleccionado
	  from temp_marsh
	 order by cod_tipo,cod_ramo	 
	 
	select trim(nombre)
	  into _nombre_ramo
	  from prdramo
	 where cod_ramo = _cod_ramo;	 	 		 	 	 
	 
    if _nueva_renov = 'R' then
	    let v_subtotal    = v_subtotal_r;
    else
	    let v_subtotal    = v_subtotal_n;
	end if 
	 
	return	_cod_agente,
			_nombre_agente,
			_no_poliza,
			_no_recibo,
			_fecha,
			_no_documento,
			_nombre_clte,
			_nom_grupo,
			_cod_grupo,
			_vigencia_inic,
			_vigencia_final,
			_estatus_desc,
			_cod_tipoprod,
			_prima_susc_n_aa,
			_prima_susc_n_ap,
			_prima_susc_r_aa,
			_prima_susc_r_ap,
			_prima_neta_cobrada,
			_porc_partic,
			_porc_comis,
			_porc_comis_adic,
			_porc_coaseguro,
			_com_adicional,
			_nueva_renov,
			_cod_ramo,
			_cod_subramo,
			_tasa,
			_cod_tipo,
			_seleccionado,
			_nombre_compania,
			_nombre_ramo,
			_per_ini_aa,
			_per_fin_aa,
			v_subtotal,
			v_total
			with resume;			 
end foreach	 
end
end procedure