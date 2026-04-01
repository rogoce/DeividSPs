-- Procedimiento que verifica el cuadre contable con las cuentas tecnicas de cobros y auxiliar(detalle)
-- Creado    : 20/11/2019 - Autor: Henry Giron
--execute procedure sp_sac251('001','001','2019-09','2019-09','*')
drop procedure sp_sac251;
create procedure informix.sp_sac251(
a_compania  char(3), 
a_agencia   char(3), 
a_periodo1  char(7), 
a_periodo2  char(7), 
a_cuenta    varchar(100))
returning	integer,
			varchar(100);
		  

   BEGIN
		DEFINE v_nopoliza                      CHAR(10);
		DEFINE v_noendoso,v_cod_contrato       CHAR(5);
		DEFINE v_cod_ramo,v_cobertura          CHAR(03);
		DEFINE v_desc_ramo, v_desc_contrato    CHAR(50);
		DEFINE v_desc_cobertura	             CHAR(100);
		DEFINE v_filtros,v_filtros1,v_filtros2 CHAR(255);
		DEFINE _tipo                           CHAR(01);
		DEFINE v_descr_cia                     CHAR(50);
		DEFINE v_prima                		 DEC(16,2);
		DEFINE v_prima1                		 DEC(16,2);
		DEFINE v_tipo_contrato                 SMALLINT;

		define _porc_impuesto					 dec(16,2);
		define _porc_comision					 dec(16,2);
		define _cuenta						 char(25);
		define _serie 						 smallint;
		define _impuesto						 dec(16,2);
		define _comision						 dec(16,2);
		define _por_pagar						 dec(16,2);

		DEFINE _cod_traspaso	 				 CHAR(5);
		define _traspaso		 				 smallint;
		define _tiene_comis_rea				 smallint;
		define _cantidad						 smallint;
		define _tipo_cont                      smallint;
			
		define _porc_cont_partic 				 dec(5,2);
		DEFINE _porc_comis_ase   				 DECIMAL(5,2);
		define _monto_reas					 dec(16,2);
		define v_prima_suscrita				 dec(16,2);
		define _cod_coasegur	 				 char(3);
		define _nombre_coas					 char(50);
		define _nombre_cob					 char(50);
		define _nombre_con					 char(50);
		define _cod_subramo					 char(3);
		define _cod_origen					 char(3);
		define _prima_tot_ret                  dec(16,2);
		define _prima_sus_tot					 dec(16,2);
		define _prima_tot_ret_sum              dec(16,2);
		define _prima_tot_sus_sum              dec(16,2);
		define _no_cambio						 smallint;
		define _no_unidad						 char(5);
		define v_prima_cobrada           		 DEC(16,2);
		define _porc_partic_coas				 dec(7,4);
		define _fecha						     date;
		define _vigencia_ini					 date;
		define _vigencia_fin					 date;
		define _porc_partic_prima				 dec(9,6);
		define _p_sus_tot						 DEC(16,2);
		define _p_sus_tot_sum					 DEC(16,2);
		define v_prima_tipo					 DEC(16,2);
		define v_prima_1 						 DEC(16,2);
		define v_prima_3 						 DEC(16,2);
		define v_prima_bq						 DEC(16,2);
		define v_prima_Ot						 DEC(16,2);
		define _bouquet						 smallint;
		DEFINE v_rango_inicial	             DEC(16,2);
		DEFINE v_rango_final	                 DEC(16,2);
		DEFINE v_suma_asegurada 				 DECIMAL(16,2);
		DEFINE v_cod_tipo						 CHAR(3);
		DEFINE v_porcentaje					 smallint;
		DEFINE _t_ramo						 CHAR(1);
		DEFINE _flag , _cnt					 smallint;
		define _sum_fac_car 				     dec(16,2);
		define _no_documento					 char(20);
		DEFINE v_no_remesa                     CHAR(10);
		define _no_registro					 char(10);
		define _sac_notrx                      integer;
		define _res_comprobante				 char(15);
		define _n_contrato                     varchar(50);

		DEFINE i_cuenta			char(12);
		DEFINE i_comprobante	CHAR(15);
		DEFINE i_fechatrx		DATE;
		DEFINE i_no_registro    char(10);
		DEFINE i_notrx			INTEGER;
		DEFINE i_auxiliar		CHAR(5);
		DEFINE i_debito			DEC(15,2);
		DEFINE i_credito		DEC(15,2);
		DEFINE i_origen			CHAR(15);
		DEFINE i_no_documento	CHAR(20);
		DEFINE i_no_poliza		CHAR(10);
		DEFINE i_no_endoso		CHAR(5);
		DEFINE i_no_remesa		CHAR(10);
		DEFINE i_renglon		smallint;
		DEFINE i_no_tranrec		CHAR(10);
		DEFINE i_mostrar         CHAR(10);
		DEFINE i_tipo            CHAR(15);

		DEFINE i_neto           DEC(15,2);
		DEFINE d_factura		CHAR(10);
		DEFINE d_poliza			CHAR(10);
		DEFINE d_endoso			CHAR(5);
		DEFINE d_debito			DEC(15,2);
		DEFINE d_credito		DEC(15,2);
		DEFINE d_renglon		smallint;
		DEFINE v_tipo_mov		CHAR(3);
		DEFINE v_nombre 		CHAR(50);
		DEFINE v_prima_bruta	DEC(16,2);
		DEFINE v_prima_neta		DEC(16,2);
		DEFINE v_impuesto		DEC(16,2);	   		   
		DEFINE v_documento		CHAR(20);
		define _cia_nom		    char(50);

		DEFINE v_nombre_cuenta   CHAR(50);
		DEFINE _no_poliza		 CHAR(10);
		DEFINE _no_endoso		 CHAR(5);
		define _error			integer;
		define _error_desc		char(50);

		define r_cod_auxiliar   char(5);
		define r_debito         DEC(16,2);
		define r_credito		DEC(16,2);
		define r_desc_rea		char(50);
		define _no_remesa       char(10);	
		define _auxiliar_nom    char(50);		  	  	
		define _renglon			integer;		
		define _cod_ramo     	char(3);
define _mto_cobasien		dec(16,2);
define _dif					dec(16,2);
define _db					dec(16,2);
define _cr					dec(16,2);		
define _cod_origen_aseg		char(3);
define _cod_auxiliar		char(5);
define _monto			    dec(16,2);
				
     SET ISOLATION TO DIRTY READ;
     LET v_descr_cia = sp_sis01(a_compania);
	drop table if exists tmp_sac213c;
	drop table if exists tmp_aux213c;
	drop table if exists tmp_cglcuentas;
	drop table if exists tmp_cglterceros;
	drop table if exists tmp_cglconcepto;
	drop table if exists tmp_contable;
	

CREATE TEMP TABLE tmp_aux213c(
		res1_notrx		  integer,	
		res1_linea	      integer,		  
		res1_cuenta       char(12),	 	
		res1_auxiliar     char(5),	 		
		res1_debito       decimal(15,2),	
		res1_credito      decimal(15,2),	
		res1_noregistro   integer, 
		res1_comprobante  char(15),
		res1_remesa       char(10),
		res1_desc_rea     char(50), 
		res1_no_documento char(20),
		res1_no_poliza    char(10),
		PRIMARY KEY(res1_notrx,res1_noregistro,res1_linea,res1_cuenta,res1_auxiliar,res1_remesa)) WITH NO LOG;

CREATE INDEX idx1_tmp_aux213c ON tmp_aux213c(res1_notrx);
CREATE INDEX idx2_tmp_aux213c ON tmp_aux213c(res1_noregistro);
CREATE INDEX idx3_tmp_aux213c ON tmp_aux213c(res1_linea);
CREATE INDEX idx4_tmp_aux213c ON tmp_aux213c(res1_cuenta);
CREATE INDEX idx5_tmp_aux213c ON tmp_aux213c(res1_auxiliar);
CREATE INDEX idx6_tmp_aux213c ON tmp_aux213c(res1_remesa);
CREATE INDEX idx7_tmp_aux213c ON tmp_aux213c(res1_no_documento);
CREATE INDEX idx8_tmp_aux213c ON tmp_aux213c(res1_no_poliza);

CREATE TEMP TABLE tmp_sac213c(
		cuenta			char(12),
		comprobante		char(15),
		fechatrx		date,
		no_registro		CHAR(10),
		auxiliar     	char(5),
		debito			DEC(15,2)   default 0,
		credito			DEC(15,2)   default 0,
		origen          char(15),
		no_documento	char(20),
		no_poliza       char(10),
		no_endoso       char(5),
		no_remesa		char(10),
		renglon			smallint,
		no_tranrec		char(10),
		notrx           integer,
		mostrar			char(10),
		tipo            char(15),		
		auxiliar_nom	char(50)
		) WITH NO LOG; 	
		
		create temp table tmp_contable(
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
		dif             dec(16,2)) with no log;

      LET v_prima         = 0;
	  let _cod_subramo    = "001";
	  let _prima_tot_ret  = 0;
	  let _prima_sus_tot  = 0;
	  let _p_sus_tot      = 0;
	  let _p_sus_tot_sum  = 0;
	  let _tipo_cont      = 0;
	  LET v_filtros1      = "";
	  LET v_filtros2      = "";
	  let _porc_comis_ase = 0;
	  LET _sum_fac_car    = 0;
	  LET v_no_remesa     = "";
	  let _sac_notrx      = 0;
	  let _n_contrato     = NULL;

--Filtro por Cuentas
if a_cuenta <> "*" then
	LET v_filtros = TRIM(v_filtros) ||" Cuenta "||TRIM(a_cuenta);
	let _tipo = sp_sis04(a_cuenta); -- separa los valores del string
end if	  


--set debug file to "sp_sac251.trc";
--trace on;

let v_nombre = " ";
let i_comprobante = " ";

select cia_nom
  into _cia_nom
  from sigman02
 where cia_bda_codigo = "sac";

select *
  from sac:cglconcepto
  into temp tmp_cglconcepto;

select *
  from sac:cglcuentas 
  into temp tmp_cglcuentas;	

select *
  from sac:cglterceros 
  into temp tmp_cglterceros;	

let _auxiliar_nom = "";

FOREACH
		select distinct r.no_remesa
		 into  _no_remesa
		 from  deivid:temp_produccion f,cobredet r
		where f.seleccionado = 1
          and f.no_poliza = r.no_poliza
          and f.no_remesa = r.no_remesa        		
		  and f.no_poliza is not null
		  and f.no_remesa is not null
		  and r.no_remesa = '1507628' 

		FOREACH	
				select b.cuenta,
				c.fecha,
				b.no_registro,
				b.debito,
				b.credito,
				decode(c.tipo_registro,"1","PRODUCCION","2","COBROS","3","RECLAMOS"),
				c.no_documento,
				c.no_poliza,
				c.no_endoso,
				c.no_remesa,
				c.renglon,
				c.no_tranrec,
				b.sac_notrx
				into i_cuenta,
					 i_fechatrx,
					 i_no_registro,
					 i_debito,
					 i_credito,
					 i_origen,
					 i_no_documento,
					 i_no_poliza,
					 i_no_endoso,
					 i_no_remesa,
					 i_renglon,
					 i_no_tranrec,
					 i_notrx
				from sac999:reacompasie b, sac999:reacomp c
				where b.no_registro = c.no_registro
				and c.tipo_registro = "2"
				and c.no_remesa = _no_remesa

					LET i_mostrar = "";
					if trim(i_origen) = "COBROS" then
						LET i_tipo = 'No. Remesa';
						LET i_mostrar = i_no_remesa;
				    end if
					LET i_auxiliar = '';										

					INSERT INTO tmp_sac213c (
					cuenta,
					comprobante,
					fechatrx,
					no_registro,
					auxiliar,
					debito,
					credito,
					origen,
					no_documento,
					no_poliza,
					no_endoso,
					no_remesa,
					renglon,
					no_tranrec,
					notrx,
					mostrar,
					tipo,					
					auxiliar_nom
					 )
					VALUES (
					i_cuenta,
					i_comprobante,		
					i_fechatrx,
					i_no_registro,
					i_auxiliar,
					i_debito,
					i_credito,
					i_origen,
					i_no_documento,
					i_no_poliza,
					i_no_endoso,
					i_no_remesa,
					i_renglon,
					i_no_tranrec,
					i_notrx,
					i_mostrar,
					i_tipo,					
					_auxiliar_nom
					);

				   	FOREACH
						select a.cod_auxiliar,
						      t.ter_descripcion,
						      sum(a.debito),
						      sum(a.credito)
						 into r_cod_auxiliar,
							  r_desc_rea,
							  r_debito,
							  r_credito	
						 from sac999:reacompasiau a ,tmp_cglterceros t	 
						where a.no_registro  = i_no_registro
						  and a.cod_auxiliar = t.ter_codigo
						  and a.cuenta       = i_cuenta 
						group by 1,2
						order by 1,2


					   	BEGIN
						ON EXCEPTION IN(-239)
						  UPDATE tmp_aux213c
						     SET res1_debito    = res1_debito + r_debito, 
							     res1_credito   = res1_credito + r_credito
						   WHERE res1_notrx     = i_notrx
							 AND res1_cuenta    = i_cuenta 
							 AND res1_auxiliar	= r_cod_auxiliar
							 AND res1_remesa    = _no_remesa; 
						END EXCEPTION 	


							INSERT INTO tmp_aux213c(
							res1_notrx,
							res1_linea,	    
							res1_cuenta,    
							res1_auxiliar,   
							res1_debito,     
							res1_credito,    
							res1_noregistro, 
							res1_comprobante,
							res1_remesa,
							res1_desc_rea,
							res1_no_documento, 
							res1_no_poliza    
							)																	
							VALUES(	
							i_notrx, 
							i_renglon, 
							i_cuenta, 
							r_cod_auxiliar, 
							r_debito, 
							r_credito,    
							i_no_registro, 
							i_comprobante,
							_no_remesa,
							r_desc_rea,
							i_no_documento,
							i_no_poliza										
							 );  
					   END 
					END FOREACH	 							   
		END FOREACH
END FOREACH

let _auxiliar_nom = "";
FOREACH
	select no_remesa,renglon,cod_ramo,cod_subramo,cod_coasegur,sum(por_pagar)
	  into _no_remesa,_renglon,_cod_ramo,_cod_subramo,_cod_coasegur,_mto_cobasien
	from temp_produccion
	where no_remesa = '1507628'	--and no_poliza = '1273235' --and cuenta = '231010201'
	group by no_remesa,renglon,cod_ramo,cod_subramo,cod_coasegur
	order by no_remesa,renglon,cod_ramo,cod_subramo,cod_coasegur
	
	if _mto_cobasien is null then
		let _mto_cobasien = 0.00;
	end if
	
	if _mto_cobasien = 0.00 then
		continue foreach;
	end if		
	
	select cod_origen,
		   aux_bouquet
	  into _cod_origen_aseg,
		   _cod_auxiliar
	  from emicoase
	 where cod_coasegur = _cod_coasegur;
	 
	let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   		
	
	if _cuenta is null then
		continue foreach;
	end if		
	
		FOREACH
		select a.res1_auxiliar, res1_notrx,  
			  t.ter_descripcion,
			  sum(a.res1_debito),
			  sum(a.res1_credito),
			  sum(a.res1_credito - a.res1_debito)			  
			  into r_cod_auxiliar,i_notrx,
				   r_desc_rea,
				   _db,
				   _cr,
				   _monto
			 from tmp_aux213c a ,tmp_cglterceros t
			where a.res1_cuenta = _cuenta
			  and a.res1_auxiliar = t.ter_codigo
			  and a.res1_remesa = _no_remesa			  
			  and a.res1_linea = _renglon
			  and a.res1_auxiliar = _cod_auxiliar
		    group by 1,2,3
			order by 1,2,3
			
			
				let _dif = 0;
				let _dif = _monto - _mto_cobasien;

				if _dif = 0 then
					continue foreach;
				end if				
			   
				insert into tmp_contable(
						cuenta,
						no_remesa,
						renglon,
						db,
						cr,
						sac_notrx,
						origen,
						descripcion,
						cod_coasegur,name_coasegur,monto_tecnico,dif)
				values(	_cuenta,
						_no_remesa,
						_renglon,
						_db,
						_cr,
						i_notrx,
						'COB',
						'DIFERENCIA ENTRE REMESA Y AUXILIAR',
						r_cod_auxiliar,r_desc_rea,_mto_cobasien,_dif);																				

			
	
		END FOREACH;	
	
END FOREACH;


return 0, 'Carga Exitosa';


{DROP TABLE temp_produccion;
DROP TABLE temp_det;}



END

END PROCEDURE


		  