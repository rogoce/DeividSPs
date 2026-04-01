-- Procedimiento que verifica el cuadre contable con las cuentas tecnicas de cobros y auxiliar
-- Creado    : 20/11/2019 - Autor: Henry Giron
--execute procedure sp_sac250('001','001','2019-09','2019-09','001,003,006,008,010,011,012,013,014,021,022;','231010201')
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_sac250a;
create procedure informix.sp_sac250a(
a_compania  char(3), 
a_agencia   char(3), 
a_periodo1  char(7), 
a_periodo2  char(7),
a_cod_ramo	varchar(100),
a_cuenta    varchar(100))
returning	varchar(50)		as compania,
			varchar(50)		as nom_cuenta,
			char(18)		as cuenta,			
			char(3)			as origen,
			dec(16,2)		as db,
			dec(16,2)		as cr,
			dec(16,2)		as monto_tecnico,
			integer			as sac_notrx,
			char(10)		as no_remesa,
			integer			as renglon,
			char(15)		as comprobante,
			char(10)		as no_tranrec,
			char(10)		as factura,
			varchar(255)	as descripcion,			
			char(50)        as name_coasegur,
			char(20)        as poliza;

define _no_documento		char(20);
define _descripcion			varchar(255);
define _error_desc			varchar(255);
define v_descr_cia	        varchar(50);
define _nom_cuenta			varchar(50);
define _cuenta				char(18);
define _res_comprobante		char(15);
define _no_factura			char(10);
define _no_tranrec			char(10);
define _no_remesa			char(10);
define _no_poliza			char(10);
define _no_endoso			char(5);
define _res_origen			char(3);
define _tipo				char(1);
define _prima_cobrada		dec(16,2);
define _mto_recasien		dec(16,2);
define _res_db				dec(16,2);
define _res_cr				dec(16,2);
define _monto				dec(16,2);
define _dif					dec(16,2);
define _db					dec(16,2);
define _cr					dec(16,2);
define _cnt_cglresumen		smallint;
define _cnt1		smallint;
define _error_isam			integer;
define _res_notrx			integer;
define _sac_notrx			integer;
define _renglon				integer;
define _error				integer;
define _fecha1				date;
define _fecha2				date;
define _cod_ramo     	    char(3);
define _cod_subramo     	char(3);
define _cod_coasegur		char(3);
define _cod_origen_aseg		char(3);
define _cod_auxiliar		char(5);	
define _name_coasegur	    char(50);
define a_codramo            char(255);
define a_serie              char(255);

define v_filtros			varchar(255);
define v_desc_ramo			varchar(50);
define _ano					char(4);
define _cod_tipoprod		char(3);
define _monto_total			dec(16,2);
define _diferencia			dec(16,2);
define _saldo				dec(16,2);
define _siniestro           dec(16,2);
define _ramo_sis			smallint;
define _mes					smallint;
DEFINE v_aux_terc		    CHAR(5);
define _cnt                 integer;
define _fecha_desde			date;
define _fecha_hasta			date;
define _monto_comprobantes  dec(16,2);
define _saldo_sin_comprob   dec(16,2);
define _diferencia2			dec(16,2);
define _saldo2				dec(16,2);

define _no_registro         char(10);
define _msg_aux             char(5);
define _msg_db              dec(16,2);
define _msg_cr              dec(16,2);
define _msg_ref             CHAR(10);
define _msg_cta             CHAR(18);
define _aux_cuenta          CHAR(18);
DEFINE i_notrx			    INTEGER;
define r_cod_auxiliar       char(5);
define _aux_aux             char(5);
define _mto_cobasien		dec(16,2);
define r_desc_rea		    char(50);
      
set isolation to dirty read;

--set debug file to "sp_sac250.trc";
--trace on;

begin 
let _no_tranrec = '';
let _prima_cobrada  = 0;
let _monto_total    = 0;
let _cod_subramo    = '001';
let _monto_comprobantes  = 0;
let _saldo_sin_comprob = 0;
let _diferencia2  = 0;
let _saldo2    = 0;
let v_descr_cia = sp_sis01(a_compania);
{
drop table if exists tmp_balance;
drop table if exists tmp_saldos;
drop table if exists temp_det;
drop table if exists tmp_produccion_ps;
drop table if exists temp_ps;
drop table if exists temp_ps_det;
drop table if exists temp_produccion;
drop table if exists tmp_contable1;
drop table if exists tmp_codigos;
drop table if exists tmp_info;

--Tabla Maestra del Procedimiento
create temp table tmp_balance(
cuenta		char(12)  not null,
cod_ramo	char(3)   not null,
monto_total	dec(16,2) default 0,
saldo		dec(16,2) default 0,
diferencia	dec(16,2) default 0,
tercero		char(5)   not null,
primary key (cuenta,cod_ramo,tercero)) with no log;

--Tabla para el proceso de saldos por cuenta.
drop table if exists tmp_saldos;
CREATE TEMP TABLE tmp_saldos(
	    periodo         CHAR(100),
		tercero         CHAR(5),
		nombre			CHAR(50),
		inicial         DEC(15,2)	default 0,
		debito          DEC(15,2)	default 0,
		credito         DEC(15,2)	default 0,   
		neto            DEC(15,2)	default 0,
		acumulado       DEC(15,2)	default 0,
		cia				CHAR(50),
		nom_cuenta		CHAR(50),
		cuenta          char(12)
		) WITH NO LOG; 	
		
drop table if exists tmp_info;
create temp table tmp_info(
cod_coasegur		char(3),
cod_ramo			char(3),
cod_contrato		char(5),
cobertura			char(3),
prima				dec(16,2),
comision			dec(16,2),
impuesto			dec(16,2),
por_pagar			dec(16,2),
siniestro			dec(16,2),
prima_tot_ret		dec(16,2),
prima_sus_tot		dec(16,2),
porc_cont_partic	dec(16,2),
desc_ramo			char(50),
desc_contrato		char(50),
por_pagar_partic	dec(16,2),
siniestro_partic	dec(16,2)) with no log;		
}
drop table if exists tmp_contable1;
	create temp table tmp_contable1(
	cuenta			char(18),
	no_remesa		char(10),
	renglon			integer,
	db				dec(16,2),
	cr				dec(16,2),
	monto_tecnico	dec(16,2),
	sac_notrx		integer,
	comprobante		char(15),
	no_tranrec		char(10),
	origen			char(3),
	no_poliza		char(10),
	no_endoso		char(10),
	descripcion		varchar(255),
	cod_coasegur    char(5),
	name_coasegur   char(50),
	dif             dec(16,2) ) with no log;
	
drop table if exists tmp_aux213c;	
CREATE TEMP TABLE tmp_aux213c(	
	Tipo_registro  smallint,
	cuenta		   char(18),
	Cod_Auxiliar   char(5),
	Auxiliar       varchar(50),
	Ramo           varchar(50),
	Poliza         char(20),
	Documento      char(20),
	Renglon        integer,
	Comprobante    char(8),
	Fechatrx       date,
	Descripcion    varchar(50),
	Db_auxiliar    dec(16,2),
	Cr_auxiliar    dec(16,2) ,
	Tot_auxiliar   dec(16,2),
    res_notrx	   integer ) with no log;

let _ano = a_periodo1[1,4];
let _mes = a_periodo1[6,7];
let _fecha_desde = mdy(a_periodo1[6,7],1,a_periodo1[1,4]);
let _fecha_hasta = sp_sis36(a_periodo1);

let a_codramo = "001,003,006,008,010,011,012,013,014,021,022,004,016,019;";
let a_serie = "2019,2018,2017,2016,2015,2014,2013,2012,2011,2010,2009,2008;";
{
--Procedure de Generacion de Primas Suscrita Facultativo para el periodo dado.
call sp_pr123h('001','001',a_periodo1,a_periodo2,"*","*","*","*",a_codramo,"*","*",a_serie,0)
returning _error, _error_desc;
if _error <> 0 then
	return	v_descr_cia,
			'',
			'',
			'',
			0.00,
			0.00,
			0.00,
			0,
			'',
			_error,
			'',
			'',
			'',
			'',
			_error_desc,
			'';		
end if

	select * 
	  from tmp_produccion_ps
	  into temp temp_ps;
	  
	select * 
	  from temp_det
	  into temp temp_ps_det;	 	  	   
	  
insert into tmp_info(
			cod_coasegur,	  
			cod_ramo,		  
			cod_contrato,	  
			cobertura,	      
			prima, 		      
			comision, 		  
			impuesto, 		  
			por_pagar,		  
			siniestro,		  
			prima_tot_ret,	  
			prima_sus_tot,	  
			porc_cont_partic, 
			desc_ramo,	      
			desc_contrato,      
			por_pagar_partic, 
			siniestro_partic) 
select 		cod_coasegur,	  
			cod_ramo,		  
			cod_contrato,	  
			cobertura,	      
			prima, 		      
			comision, 		  
			impuesto, 		  
			por_pagar,		  
			siniestro,		  
			prima_tot_ret,	  
			prima_sus_tot,	  
			porc_cont_partic, 
			desc_ramo,	      
			desc_contrato,      
			por_pagar, 
			siniestro
from temp_imformef;		  
}
{
--Procedure de Generacion de Primas Cobrada para el periodo dado.
call sp_pr860h('001','001',a_periodo1,a_periodo2,"*","*","*","*",a_codramo,"*",a_serie,"01","*")
returning _error, _error_desc;
if _error <> 0 then
	return	v_descr_cia,
			'',
			'',
			'',
			0.00,
			0.00,
			0.00,
			0,
			'',
			_error,
			'',
			'',
			'',
			'',
			_error_desc,
			'';			
end if

insert into tmp_info(
			cod_coasegur,	  
			cod_ramo,		  
			cod_contrato,	  
			cobertura,	      
			prima, 		      
			comision, 		  
			impuesto, 		  
			por_pagar,		  
			siniestro,		  
			prima_tot_ret,	  
			prima_sus_tot,	  
			porc_cont_partic, 
			desc_ramo,	      
			desc_contrato,      
			por_pagar_partic, 
			siniestro_partic) 
select 		cod_coasegur,	  
			cod_ramo,		  
			cod_contrato,	  
			cobertura,	      
			prima, 		      
			comision, 		  
			impuesto, 		  
			por_pagar,		  
			siniestro,		  
			prima_tot_ret,	  
			prima_sus_tot,	  
			porc_cont_partic, 
			desc_ramo,	      
			desc_contrato,      
			por_pagar_partic, 
			siniestro_partic
from temp_informe;	
		

}

foreach
	select distinct cod_ramo,cod_coasegur
	  into _cod_ramo,_cod_coasegur
	from tmp_info	
	order by cod_ramo, cod_coasegur					

	select cod_origen,
		   aux_bouquet
	  into _cod_origen_aseg,
		   _cod_auxiliar
	  from emicoase
	 where cod_coasegur = _cod_coasegur;
	 
	let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo,_cod_subramo);   	
	let _cnt = 0;
	select count(*)
	  into _cnt
	  from tmp_aux213c
	 where cuenta = _cuenta
	   and Cod_Auxiliar = _cod_auxiliar ;
	   
	if _cnt = 0 then 
	
		call sp_sac251a(a_periodo1,_cuenta) returning _error, _error_desc;	
		if _error <> 0 then
			return 'Cuadre Contable, Error: ' || trim(_error_desc),'',_cuenta,'',0.00,0.00,0.00,_error,'',0,'','','','','','';
			
		end if
	end if
	
end foreach	 

foreach
	 select distinct r.no_registro,r.no_remesa,r.renglon
	   into _no_registro,_no_remesa,_renglon
	   from sac999:reacomp r, temp_det  c
	  where r.no_poliza = c.no_poliza
        and r.no_remesa = c.no_remesa
	    and r.tipo_registro = 2		
		and c.no_remesa is not null
		and c.renglon is not null
		and c.seleccionado = 1
	--	and r.no_remesa = '1507628'
  -- group by r.no_registro
   order by r.no_registro,r.no_remesa,r.renglon
   
   call sp_par296_cta(_no_registro) returning _error, _error_desc, _msg_cta, _msg_aux,_msg_db,_msg_cr,_msg_ref;
	
	if _error = 0 then
		foreach
			select a.cuenta ,b.aux_bouquet,sum(abs(a.debito) - abs(a.credito))
			  into _aux_cuenta,_aux_aux, _mto_cobasien
			from tmp0_cta a, emicoase b	
			where a.cuenta like ('231%') 
			  and b.cod_auxiliar = a.cod_auxiliar
              group by a.cuenta,b.aux_bouquet
			
			
				if _mto_cobasien is null then
					let _mto_cobasien = 0;
				end if

					
			select sum(abs(a.Db_auxiliar) - abs(a.Cr_auxiliar))			  
			  into  _monto
			 from tmp_aux213c a ,tmp_cglterceros t
			where a.cuenta = _aux_cuenta
			  and a.Cod_Auxiliar = t.ter_codigo
			  and a.Cod_Auxiliar = _aux_aux
			  and a.Tipo_registro = 2
			  and a.documento = _no_remesa
              and a.renglon = _renglon;
			  
			if _monto is null then
				let _monto = 0;
			end if			  
			
			let _dif = 0;
			let _dif = _monto - _mto_cobasien;

				if _dif = 0 then
					continue foreach;
				end if	
-- cobros
if _no_remesa = '1507628' then
 set debug file to "sp_sac251.trc";
 trace on;	 
 let _monto = _monto;
 let _mto_cobasien = _mto_cobasien;
 let _no_registro = _no_registro;
 let _no_remesa = _no_remesa;
 let _renglon = _renglon;
 trace off;	
end if
			FOREACH
			select a.Cod_Auxiliar, a.Documento,a.Renglon,
			      a.Comprobante, a.res_notrx,  
				  t.ter_descripcion,
				  sum(a.Db_auxiliar),
				  sum(a.Cr_auxiliar),
				  sum(a.Db_auxiliar - a.Cr_auxiliar)			  
				  into r_cod_auxiliar,_no_remesa,_renglon,_res_comprobante, i_notrx,
					   r_desc_rea,
					   _db,
					   _cr,
					   _monto
				 from tmp_aux213c a ,tmp_cglterceros t
				where a.cuenta = _aux_cuenta
				  and a.Cod_Auxiliar = t.ter_codigo
				  and a.Cod_Auxiliar = _aux_aux
				  and a.documento = _no_remesa
                  and a.renglon = _renglon
				group by 1,2,3,4,5,6
				order by 1,2,3,4,5,6
			
			   
				insert into tmp_contable1(
						cuenta,
						no_remesa,
						renglon,
						db,
						cr,
						sac_notrx,
						origen,
						descripcion,
						cod_coasegur,name_coasegur,monto_tecnico,dif,comprobante)
				values(	_aux_cuenta,
						_no_remesa,
						_renglon,
						_db,
						_cr,
						i_notrx,
						'COB',
						'DIFERENCIA ENTRE REMESA Y AUXILIAR',
						r_cod_auxiliar,r_desc_rea,_mto_cobasien,_dif,_res_comprobante);	

			END FOREACH;						
		--end if	
		end foreach
	end if
end foreach
{
foreach
	select a.no_remesa,a.renglon,b.cod_ramo,b.cod_coasegur,sum(b.por_pagar_partic)
	into _no_remesa,_renglon,_cod_ramo,_cod_coasegur,_prima_cobrada
	from temp_det a, tmp_info b
	where a.seleccionado = 1
	and a.cod_ramo = b.cod_ramo	
	group by a.no_remesa,a.renglon,b.cod_ramo,b.cod_coasegur
	order by a.no_remesa,a.renglon,b.cod_ramo,b.cod_coasegur
	
	
	if _prima_cobrada is null then
		let _prima_cobrada = 0.00;
	end if
	
	if _prima_cobrada = 0.00 then
		continue foreach;
	end if		   

	select cod_origen,
		   aux_bouquet
	  into _cod_origen_aseg,
		   _cod_auxiliar
	  from emicoase
	 where cod_coasegur = _cod_coasegur;
	 
	let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   	 			
	
	select count(*)
	  into _cnt1
	  from tmp_aux213c
	 where cuenta = _cuenta
	   and Cod_Auxiliar = _cod_auxiliar
	   and documento = _no_remesa
       and renglon = _renglon;

	if _cnt1 is null then
		let _cnt1 = 0;
	end if

	if _cnt1 = 0 then							
						
		insert into tmp_contable1(
				cuenta,
				no_remesa,
				renglon,
				db,
				cr,
				sac_notrx,
				origen,
				monto_tecnico,
				descripcion,
				cod_coasegur)
		values(	_cuenta,
				_no_remesa,
				_renglon,
				0.00,
				0.00,
				'',
				'COB',
				_prima_cobrada,
				'NO EXISTE ASIENTO DE AUILIAR EN LA REMESA',
				_cod_auxiliar);
	
	end if
	
end foreach
}	    
--************ temp_devpri_det
foreach
select r.no_registro,c.no_documento,c.no_factura
  into _no_registro,_no_documento,_no_factura
   from sac999:reacomp r, temp_devpri_det  c
  where r.no_poliza 	= c.no_poliza
    and r.tipo_registro = 1
    and c.seleccionado = 1
   group by r.no_registro,c.no_documento,c.no_factura
   order by r.no_registro,c.no_documento,c.no_factura

   
   call sp_par296_cta(_no_registro) returning _error, _error_desc, _msg_cta, _msg_aux,_msg_db,_msg_cr,_msg_ref;
	
	if _error = 0 then
		foreach
			select a.cuenta ,b.aux_bouquet,sum(abs(a.debito) - abs(a.credito))
			  into _aux_cuenta,_aux_aux, _mto_cobasien
			from tmp0_cta a, emicoase b	
			where a.cuenta like ('231%') 
			  and b.cod_auxiliar = a.cod_auxiliar
              group by a.cuenta,b.aux_bouquet
			
			
				if _mto_cobasien is null then
					let _mto_cobasien = 0;
				end if

					
			select sum(abs(a.Db_auxiliar) - abs(a.Cr_auxiliar))			  
			  into  _monto
			 from tmp_aux213c a ,tmp_cglterceros t
			where a.cuenta = _aux_cuenta
			  and a.Cod_Auxiliar = t.ter_codigo
			  and a.Cod_Auxiliar = _aux_aux
			  and a.Tipo_registro = 2
			  and a.documento = _no_factura
              and a.poliza = _no_documento;
			  
			if _monto is null then
				let _monto = 0;
			end if			  
			
			let _dif = 0;
			let _dif = _monto - _mto_cobasien;

				if _dif = 0 then
					continue foreach;
				end if	
-- produccion
if _no_factura = '1507628' then
 set debug file to "sp_sac251p.trc";
 trace on;	 
 let _monto = _monto;
 let _mto_cobasien = _mto_cobasien;
 let _no_registro = _no_registro;
 let _no_documento = _no_documento;
 let _no_factura = _no_factura;
 trace off;	
end if
			FOREACH
			select a.Cod_Auxiliar, a.Documento,a.poliza,
			      a.Comprobante, a.res_notrx,  
				  t.ter_descripcion,
				  sum(a.Db_auxiliar),
				  sum(a.Cr_auxiliar),
				  sum(a.Db_auxiliar - a.Cr_auxiliar)			  
				  into r_cod_auxiliar,_no_factura,_no_documento,_res_comprobante, i_notrx,
					   r_desc_rea,
					   _db,
					   _cr,
					   _monto
				 from tmp_aux213c a ,tmp_cglterceros t
				where a.cuenta = _aux_cuenta
				  and a.Cod_Auxiliar = t.ter_codigo
				  and a.Cod_Auxiliar = _aux_aux
				  and a.documento = _no_factura
                  and a.poliza = _no_documento
				group by 1,2,3,4,5,6
				order by 1,2,3,4,5,6
			
			   
				insert into tmp_contable1(
						cuenta,
						no_poliza,
						--no_endoso,
						no_tranrec,
						db,
						cr,
						sac_notrx,
						origen,
						descripcion,
						cod_coasegur,name_coasegur,monto_tecnico,dif,comprobante)
				values(	_aux_cuenta,
						_no_documento,
						--_no_endoso,
						_no_factura,
						_db,
						_cr,
						i_notrx,
						'PRO',
						'DIFERENCIA ENTRE REMESA Y AUXILIAR',
						r_cod_auxiliar,r_desc_rea,_mto_cobasien,_dif,_res_comprobante);	

			END FOREACH;						
		--end if	
		end foreach
	end if
end foreach
--*********		
--************ tmp_sinis
foreach
	 select r.no_registro ,c.doc_poliza, a.no_tranrec
	   into _no_registro,_no_documento,_no_factura
	   from sac999:reacomp r, tmp_sinis c, rectrmae a
	  where r.no_poliza  = c.no_poliza
        and r.no_tranrec = a.no_tranrec
        and c.numrecla = a.numrecla
        and c.no_reclamo = a.no_reclamo
        and c.transaccion = a.transaccion
	    and r.tipo_registro = 3
     and c.seleccionado = 1
   group by r.no_registro ,c.doc_poliza,a.no_tranrec
   order by r.no_registro,c.doc_poliza,a.no_tranrec   
  
   call sp_par296_cta(_no_registro) returning _error, _error_desc, _msg_cta, _msg_aux,_msg_db,_msg_cr,_msg_ref;
	
	if _error = 0 then
		foreach
			select a.cuenta ,b.aux_bouquet,sum(abs(a.debito) - abs(a.credito))
			  into _aux_cuenta,_aux_aux, _mto_cobasien
			from tmp0_cta a, emicoase b	
			where a.cuenta like ('231%') 
			  and b.cod_auxiliar = a.cod_auxiliar
              group by a.cuenta,b.aux_bouquet
			
			
				if _mto_cobasien is null then
					let _mto_cobasien = 0;
				end if

					
			select sum(abs(a.Db_auxiliar) - abs(a.Cr_auxiliar))			  
			  into  _monto
			 from tmp_aux213c a ,tmp_cglterceros t
			where a.cuenta = _aux_cuenta
			  and a.Cod_Auxiliar = t.ter_codigo
			  and a.Cod_Auxiliar = _aux_aux
			  and a.Tipo_registro = 2
			  and a.documento = _no_factura
              and a.poliza = _no_documento;
			  
			if _monto is null then
				let _monto = 0;
			end if			  
			
			let _dif = 0;
			let _dif = _monto - _mto_cobasien;

				if _dif = 0 then
					continue foreach;
				end if	
-- produccion
if _no_factura = '2228190' then
 set debug file to "sp_sac251r.trc";
 trace on;	 
 let _monto = _monto;
 let _mto_cobasien = _mto_cobasien;
 let _no_registro = _no_registro;
 let _no_documento = _no_documento;
 let _no_factura = _no_factura;
 trace off;	
end if
			FOREACH
			select a.Cod_Auxiliar, a.Documento,a.poliza,
			      a.Comprobante, a.res_notrx,  
				  t.ter_descripcion,
				  sum(a.Db_auxiliar),
				  sum(a.Cr_auxiliar),
				  sum(a.Db_auxiliar - a.Cr_auxiliar)			  
				  into r_cod_auxiliar,_no_factura,_no_documento,_res_comprobante, i_notrx,
					   r_desc_rea,
					   _db,
					   _cr,
					   _monto
				 from tmp_aux213c a ,tmp_cglterceros t
				where a.cuenta = _aux_cuenta
				  and a.Cod_Auxiliar = t.ter_codigo
				  and a.Cod_Auxiliar = _aux_aux
				  and a.documento = _no_factura
                  and a.poliza = _no_documento
				group by 1,2,3,4,5,6
				order by 1,2,3,4,5,6
			
			   
				insert into tmp_contable1(
						cuenta,
						no_poliza,
						--no_endoso,
						no_tranrec,
						db,
						cr,
						sac_notrx,
						origen,
						descripcion,
						cod_coasegur,name_coasegur,monto_tecnico,dif,comprobante)
				values(	_aux_cuenta,
						_no_documento,
						--_no_endoso,
						_no_factura,
						_db,
						_cr,
						i_notrx,
						'REC',
						'DIFERENCIA ENTRE REMESA Y AUXILIAR',
						r_cod_auxiliar,r_desc_rea,_mto_cobasien,_dif,_res_comprobante);	

			END FOREACH;						
		--end if	
		end foreach
	end if
end foreach
--*********	
foreach
	select cuenta,
		   no_remesa,
		   renglon,
		   db,
		   cr, 
		   sac_notrx,
		   comprobante,
		   origen,
		   monto_tecnico,
		   no_poliza,
		   no_endoso,
		   descripcion,
		   cod_coasegur,
		   name_coasegur,
		   dif,
		   no_tranrec
	  into _cuenta,
	       _no_remesa,
		   _renglon,
		   _db,
		   _cr,
		   _res_notrx,
		   _res_comprobante,
		   _res_origen,
		   _prima_cobrada,
		   _no_poliza,
		   _no_endoso,
		   _descripcion,
		   _cod_coasegur,
		   _name_coasegur,
		   _dif,
		   _no_tranrec
	  from tmp_contable1
	 order by cuenta,origen,name_coasegur,sac_notrx

	select cta_nombre
	  into _nom_cuenta
	  from cglcuentas
	 where cta_cuenta = _cuenta;
	 
	select trim(no_documento)
	  into _no_documento
	  from temp_det
	 where no_remesa = _no_remesa
	   and renglon = _renglon;	 	 

	return	v_descr_cia,
			_nom_cuenta,
			_cuenta,
			_res_origen,
			_db,
			_cr,
			_prima_cobrada,
			_res_notrx,
			_no_remesa,
			_renglon,
			_res_comprobante,
			_no_tranrec,
			_no_remesa,
			_descripcion,
			_name_coasegur,
			_no_documento
			with resume;
end foreach
end



end procedure;