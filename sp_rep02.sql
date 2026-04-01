-- Procedimiento que carga los datos para el acuerdo bono de participacion de utilidades
 
-- Creado     :	04/03/2015 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rep02;		

create procedure "informix".sp_rep02(a_periodo1 char(7), a_periodo2 char(7))
returning integer, varchar(30);

define _no_documento 	varchar(20);
define _periodo      	varchar(7);
define _cod_ramo     	varchar(3);
define _cod_subramo  	varchar(3);
define _fronting     	smallint;
define _concurso     	smallint;
define _cod_agente   	varchar(10);
define _cod_agentes   	varchar(10);
define _cnt_concurso 	smallint;
define _no_poliza    	varchar(10);
define _cod_sucursal 	varchar(3);
define _fecha_periodo   date;
define v_por_vencer     dec(16,2);  
define v_exigible       dec(16,2);
define v_corriente      dec(16,2);
define v_monto_30       dec(16,2);
define v_monto_60       dec(16,2);
define v_monto_90       dec(16,2);
define v_saldo          dec(16,2);
define _pri_dev_aa      dec(16,2);
define _no_endoso       varchar(10);  
define _cod_compania    char(3);      
define _ano				integer;
define _mes_evaluar		smallint;
define _ano_evaluar		smallint;
define _mes_pnd			smallint;
define _ano_pnd			smallint;
define _periodo_pnd1	char(7);
define _periodo_pnd2	char(7);
define _cod_ramos       varchar(200);
define _filtros         varchar(200);
define _incurrido_bruto dec(16,2);
define _fecha_inicio    date;
define _error			integer;
define _error_isam		integer;
define _error_desc		char(50); 
define _vigenteap_per   integer;       
define _renovap_per     integer;
define _renovaa_per     integer;
define _cnt             smallint;
define _prima_fac       dec(16,2);
define _nombre_agente   varchar(30);
define _ramo_nombre     varchar(30);
define _subramo_nombre  varchar(30);

let _cod_compania = '001';
let _vigenteap_per = 0;
let _renovap_per  = 0;
let _renovaa_per  = 0;


CREATE  TEMP TABLE tmp_utilidades(
		no_poliza            varchar(10),
		no_endoso            varchar(10),
		no_documento         CHAR(20),
		cod_agente			 CHAR(5),
	    cod_ramo             CHAR(3),
	    cod_subramo          CHAR(3),
		periodo              CHAR(7),
		saldo_90             dec(16,2),
		incurrido_bruto      DEC(16,2),
		prima_devengada      DEC(16,2),
		polizas_renov_aa     integer default 0,
		polizas_ap           integer default 0,
		polizas_renov_ap     integer default 0,
		PRIMARY KEY (no_poliza,no_endoso,no_documento,cod_agente)
		) WITH NO LOG;
		CREATE INDEX idx_01_tmp_sinis ON tmp_utilidades(no_documento);
		
CREATE  TEMP TABLE tmp_utilidades_doc(
		--no_poliza              varchar(10),
		--no_endoso            varchar(10),
		no_documento         CHAR(20),
		cod_agente			 CHAR(5),
		nombre_agente        varchar(30),
	    cod_ramo             CHAR(3),
		ramo_nombre          varchar(30),
	    cod_subramo          CHAR(3),
		subramo_nombre       varchar(30),
		periodo              CHAR(7),
		saldo_90             dec(16,2),
		incurrido_bruto      DEC(16,2),
		prima_devengada      DEC(16,2),
		polizas_renov_aa     integer default 0,
		polizas_ap           integer default 0,
		polizas_renov_ap     integer default 0,
		PRIMARY KEY (no_documento,cod_agente)
		) WITH NO LOG;
		CREATE INDEX idx_01_tmp_sinis_doc ON tmp_utilidades_doc(no_documento);


		let _fecha_inicio     = sp_sis36(a_periodo1);  --30/09/2014		
		let _fecha_periodo     = sp_sis36(a_periodo2);  --30/09/2014
		
-- busco los no_polizas que entran --rehabilitada o cancelada en el periodo del concurso no va
foreach
  select no_poliza,
         no_endoso,
		 no_documento
    into _no_poliza,
	     _no_endoso,
		 _no_documento
    from endedmae
   where actualizado  = 1
     and cod_endomov not in ('003','002') 
     and periodo      >= a_periodo1
	 and periodo      <= a_periodo2
	 group by 1,2,3
	 
	--call sp_sis21(_no_documento) returning _no_poliza;
	
	select cod_ramo,
		   fronting,
		   cod_subramo,
		   cod_sucursal,
		   periodo
	  into _cod_ramo,
		   _fronting,
		   _cod_subramo,
		   _cod_sucursal,
		   _periodo
	  from emipomae
	 where no_poliza = _no_poliza
	   and actualizado  = 1;
	 
	if _fronting = 1 then -- Excluir del Concurso
		continue foreach;
	end if
	
	select concurso
	  into _concurso
	  from prdsubra
	 where cod_ramo    = _cod_ramo
	   and cod_subramo = _cod_subramo;
	   
	if _concurso = 0 then -- Excluir del Concurso
		continue foreach;
	 end if  
	
	foreach	
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza

		select count(*)
		  into _cnt_concurso
		  from profit
		 where cod_agente = _cod_agente;
		
		 if _cnt_concurso = 0 then -- Excluir del Concurso
			continue foreach;
		 end if
	insert into tmp_utilidades(no_poliza, no_endoso, no_documento, cod_agente,cod_ramo, cod_subramo, periodo, saldo_90, incurrido_bruto, prima_devengada,polizas_renov_aa,polizas_ap,polizas_renov_ap)
	values (_no_poliza, _no_endoso, _no_documento, _cod_agente, _cod_ramo, _cod_subramo,_periodo,0,0,0,0,0,0);                                                     
	                                                                                                                               
	end foreach 
	
end foreach
--

-- Primas Devengadas (Primas Suscritas Devengadas PND)

let _mes_evaluar  = a_periodo2[6,7];
let _ano_evaluar  = a_periodo2[1,4];

for _mes_pnd = _mes_evaluar to 1 step -1

	if _mes_pnd = 12 then

		let _periodo_pnd1 = _ano_evaluar || "-01";

	else
		
		if _mes_pnd < 10 then
			let _periodo_pnd1 = _ano_evaluar - 1 || "-0" || _mes_pnd + 1;
		else
			let _periodo_pnd1 = _ano_evaluar - 1 || "-" || _mes_pnd + 1;
		end if

	end if

	if _mes_pnd < 10 then
		let _periodo_pnd2 = _ano_evaluar || "-0" || _mes_pnd;
	else
		let _periodo_pnd2 = _ano_evaluar || "-" || _mes_pnd;
	end if

	foreach
	 select no_poliza, 
	        no_endoso,
			no_documento
	   into _no_poliza,
		    _no_endoso,
			_no_documento
       from tmp_utilidades
	   
			 select sum(prima_suscrita)
			   into _pri_dev_aa
			   from endedmae
			  where no_poliza = _no_poliza
			    and no_endoso = _no_endoso
				and no_documento = _no_documento
				and actualizado  = 1			  
			    and periodo      >= _periodo_pnd1
				and periodo      <= _periodo_pnd2;		
				
				select sum(c.prima)
				  into _prima_fac
				  from emifacon c, reacomae r
				 where c.no_poliza = _no_poliza
				   and c.no_endoso = _no_endoso
				   and r.cod_contrato = c.cod_contrato
				   and r.tipo_contrato = 3;
				
				if _prima_fac is null then
					let _prima_fac =0.00;
				end if
				
				if _pri_dev_aa is null then
					let _pri_dev_aa =0.00;
				end if
				
				let _pri_dev_aa = _pri_dev_aa - _prima_fac;

				let _pri_dev_aa = _pri_dev_aa / 12;

				update tmp_utilidades
				   set prima_devengada  = _pri_dev_aa
				 where no_documento 	= _no_documento
				   and no_poliza 		= _no_poliza
				   and no_endoso 		= _no_endoso;
        
	end foreach

end for
--- agrupar por numero de documento agente ramo subramo
foreach
	select no_documento,
	       cod_agente,
		   cod_ramo,
		   cod_subramo,
		   sum(prima_devengada)
	  into _no_documento,
		   _cod_agente,
		   _cod_ramo,
		   _cod_subramo,
		   _pri_dev_aa
	  from tmp_utilidades
	group by 1,2,3,4
	
	select nombre
	  into _nombre_agente
	  from agtagent
	 where cod_agente = _cod_agente;
	 
	select nombre
	  into _ramo_nombre
	  from prdramo
	 where cod_ramo = _cod_ramo;
	 
    select nombre
	  into _subramo_nombre
	  from prdsubra
	 where cod_ramo = _cod_ramo
	   and cod_subramo = _cod_subramo;
	
		call sp_cob33(_cod_compania, _cod_sucursal, _no_documento, a_periodo2, _fecha_periodo)
	     returning v_por_vencer,    
	               v_exigible,      
	               v_corriente,    
	               v_monto_30,      
	               v_monto_60,      
	               v_monto_90,
	               v_saldo;

	insert into tmp_utilidades_doc(no_documento, cod_agente,nombre_agente,cod_ramo, ramo_nombre, cod_subramo,subramo_nombre, saldo_90, incurrido_bruto, prima_devengada,polizas_renov_aa,polizas_ap,polizas_renov_ap)
	values (_no_documento, _cod_agente, _nombre_agente, _cod_ramo, _ramo_nombre, _cod_subramo,_subramo_nombre,v_monto_90,0,_pri_dev_aa,0,0,0);                                                     
end foreach


let _cod_ramos = "";
let _cod_agentes = "";
	foreach
			select cod_ramo
			  into _cod_ramo
			  from prdramo 
			 where concurso = 1
		  order by cod_ramo
		 let _cod_ramos = _cod_ramo ||","||_cod_ramos;
	end foreach
-- incurrido
call sp_rec01(_cod_compania, "001", a_periodo1, a_periodo2,'*','*',_cod_ramos||";") returning _filtros;

	foreach
		select doc_poliza, 
			   cod_agente, 
			   incurrido_bruto
		  into _no_documento,
		       _cod_agente,
			   _incurrido_bruto
		  from tmp_sinis
		 where seleccionado = 1
		 
		 update tmp_utilidades_doc
			set incurrido_bruto = _incurrido_bruto
		  where no_documento = _no_documento
		    and cod_agente = _cod_agente;
	end foreach
 
drop table tmp_sinis;

	-- periodo 2014 conteo de polizas
		call sp_bo077(_fecha_inicio, _fecha_periodo) returning _error, _error_desc;
		if _error <> 0 then 
			return _error, _error_desc;
		end if
		foreach
			 select no_documento
			   into _no_documento
			   from tmp_utilidades
			   
				 select sum(no_pol_renov_per)
				   into _renovaa_per
				   from tmp_persis
				  where no_documento = _no_documento
			   group by no_documento;
			   
				 update tmp_utilidades_doc
					set polizas_renov_aa = _renovaa_per
				  where no_documento 	= _no_documento;
			   
		end foreach
	-- fin del periodo del 2014
drop table tmp_persis;	
	-- periodo 2013 conteo de polizas
		call sp_bo077('01/01/2013','31/12/2013') returning _error, _error_desc;
		if _error <> 0 then 
			return _error, _error_desc;
		end if
		foreach
			 select no_documento
			   into _no_documento
			   from tmp_utilidades_doc
			   
				 select sum(no_pol_nueva_per),
						sum(no_pol_renov_per)
				   into _vigenteap_per,
						_renovap_per
				   from tmp_persis
				  where no_documento = _no_documento
			   group by no_documento;  
			   
				 update tmp_utilidades_doc
					set polizas_ap    		= _vigenteap_per,
						polizas_renov_ap  	= _renovap_per
				  where no_documento 		= _no_documento;
			   
		end foreach
	-- fin del periodo del 2013	


drop table tmp_utilidades;
--drop table tmp_utilidades_doc
drop table tmp_persis;

return 0, 'Actualizacion Exitosa';

end procedure