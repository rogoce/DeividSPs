-- Procedimiento que verifica el cuadre contable con las cuentas tecnicas de cobros y auxiliar(detalle)
-- Creado    : 20/11/2019 - Autor: Henry Giron
--execute procedure sp_sac251a('2019-09','231010201')

drop procedure sp_sac251a;
create procedure sp_sac251a(a_periodo char(7), a_cuenta varchar(30))
returning	integer,
			varchar(100);	
			
{returning	smallint	as Tipo_registro,
			char(5)		as Cod_Auxiliar,
			varchar(50)	as Auxiliar,
			varchar(50)	as Ramo,
			char(20)	as Poliza,
			char(20)	as Documento,
			integer		as Renglon,
			char(8)		as Comprobante,
			date		as Fechatrx,
			varchar(50)	as Descripcion,
			dec(16,2)	as Db_auxiliar,
			dec(16,2)	as Cr_auxiliar,
			dec(16,2)	as Tot_auxiliar;}

define _error_desc			varchar(100);
define _res_descripcion		varchar(50);
define _nom_auxiliar		varchar(50);
define _nom_ramo			varchar(50);
define _no_documento		char(20);
define _no_tranrec			char(10);
define _documento			char(10);
define _no_remesa			char(10);
define _no_poliza			char(10);
define _res_comprobante		char(8);
define _res1_auxiliar		char(5);
define _no_endoso			char(5);
define _res_origen			char(3);
define _db_auxiliar			dec(16,2);
define _cr_auxiliar			dec(16,2);
define _tot_auxiliar		dec(16,2);
define _tipo_registro		smallint;
define _error_isam			integer;
define _res_notrx			integer;
define _renglon				integer;
define _error				integer;
define _res_fechatrx		date;
define _fecha_desde			date;
define _fecha_hasta			date;
define _no_registro         char(10);
define _msg_aux             char(5);
define _msg_db              dec(16,2);
define _msg_cr              dec(16,2);
define _msg_ref             CHAR(10);
define _msg_cta             CHAR(18);
define _cod_coasegur	 	char(3);
DEFINE i_notrx			    INTEGER;
define r_cod_auxiliar       char(5);
define _aux_aux             char(5);
define _mto_cobasien		dec(16,2);
define _dif					dec(16,2);
define _db					dec(16,2);
define _cr					dec(16,2);
define _monto			    dec(16,2);
define r_desc_rea		char(50);
		
let _tot_auxiliar = 0;
drop table if exists tmp_cglcuentas;
select *
  from sac:cglcuentas 
  into temp tmp_cglcuentas;	
drop table if exists tmp_cglterceros;
select *
  from sac:cglterceros 
  into temp tmp_cglterceros;	

--set debug file to 'sp_sac251a.trc';
--trace on;
{
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
}		
begin
on exception set _error,_error_isam,_error_desc
    --rollback work;
	return _error,_error_desc;
end exception  

set isolation to dirty read;

let _fecha_desde = mdy(a_periodo[6,7],1,a_periodo[1,4]);
let _fecha_hasta = sp_sis36(a_periodo);

foreach
	select res_descripcion,
		   res_comprobante,
		   res_fechatrx,
		   res_notrx,
		   res_origen,
		   res1_auxiliar,
		   res1_debito,
		   res1_credito
	  into _res_descripcion,
		   _res_comprobante,
		   _res_fechatrx,
		   _res_notrx,
		   _res_origen,
		   _res1_auxiliar,
		   _db_auxiliar,
		   _cr_auxiliar
	  from cglresumen, cglresumen1, emicoase
	 where res_noregistro = res1_noregistro
	   and aux_bouquet = res1_auxiliar
	   and res_cuenta = a_cuenta
	   and res_fechatrx between _fecha_desde and _fecha_hasta
	   --and res1_auxiliar  =  a_aux
	   --and res_comprobante in ('09-00012','REA09191')

	foreach
		select nombre,cod_coasegur 
		  into _nom_auxiliar,_cod_coasegur
		  from emicoase
		 where aux_bouquet = _res1_auxiliar		 
	end foreach
	


	if _res_origen = 'REA' then
		foreach
			select m.tipo_registro,
				   m.no_poliza,
				   m.no_endoso,
				   m.no_remesa,
				   m.renglon,
				   m.no_tranrec,
				   m.no_documento,
				   r.nombre,
				   d.debito,
				   d.credito
			  into _tipo_registro,
				   _no_poliza,
				   _no_endoso,
				   _no_remesa,
				   _renglon,
				   _no_tranrec,
				   _no_documento,
				   _nom_ramo,
				   _db_auxiliar,
				   _cr_auxiliar
			  from sac999:reacomp m, sac999:reacompasiau d,emipomae e, prdramo r,sac999:reacompasie p
			 where m.no_registro = d.no_registro
			   and m.no_poliza = e.no_poliza
			   and e.cod_ramo = r.cod_ramo
			   and p.no_registro = d.no_registro
			   and p.cuenta = d.cuenta
			   and p.sac_notrx = _res_notrx
			   and d.periodo = a_periodo --'2016-10'
			   and d.cod_auxiliar = _res1_auxiliar --'BQ128'
			   and d.cuenta = a_cuenta --'2550101'
			 order by 1
			 
			let _tot_auxiliar = _db_auxiliar - _cr_auxiliar ;

			if _tipo_registro = 1 then		--Producción
				select no_factura
				  into _documento
				  from endedmae
				 where no_poliza = _no_poliza
				   and no_endoso = _no_endoso;
			elif _tipo_registro in (2,4,5) then	--Cobros, Cheques Pagados y Cheques Anulados
				let _documento = _no_remesa;
			elif _tipo_registro = 3 then	--Reclamos
				select transaccion
				  into _documento
				  from rectrmae
				 where no_tranrec = _no_tranrec;
			end if				

					INSERT INTO tmp_aux213c(
					Tipo_registro,cuenta,
					Cod_Auxiliar,
					Auxiliar,
					Ramo,
					Poliza,
					Documento,
					Renglon,
					Comprobante,
					Fechatrx,
					Descripcion,
					Db_auxiliar,
					Cr_auxiliar,
					Tot_auxiliar,
                    res_notrx					
					)																	
					VALUES(	
					_tipo_registro,a_cuenta,
					_res1_auxiliar,
					_nom_auxiliar,
					_nom_ramo,
					_no_documento,
					_documento,
					_renglon,
					_res_comprobante,
					_res_fechatrx,
					_res_descripcion,
					_db_auxiliar,
					_cr_auxiliar,
					_tot_auxiliar,
                    _res_notrx					
					 );  
							 
			
		
		end foreach
	else
	
		let _tot_auxiliar = _db_auxiliar - _cr_auxiliar;
		
					INSERT INTO tmp_aux213c(
					Tipo_registro,cuenta,
					Cod_Auxiliar,
					Auxiliar,
					Ramo,
					Poliza,
					Documento,
					Renglon,
					Comprobante,
					Fechatrx,
					Descripcion,
					Db_auxiliar,
					Cr_auxiliar,
					Tot_auxiliar,
                    res_notrx					
					)																	
					VALUES(	
					0,a_cuenta,
					_res1_auxiliar,
					_nom_auxiliar,
					'COMPROBANTE MANUAL',
					'',
					'',
					0,
					_res_comprobante,
					_res_fechatrx,
					_res_descripcion,
					_db_auxiliar,
					_cr_auxiliar,
					_tot_auxiliar,
                    _res_notrx					
					 );  		

	
	end if
end foreach
{
-- produccion
foreach
 select r.no_registro,
         r.tipo_registro
   into _no_registro,
	    _tipo_registro
  from sac999:reacomp r, temp_devpri_det  c
  where r.no_poliza 	= c.no_poliza
    and r.tipo_registro = 1
    and c.seleccionado = 1
   group by r.no_registro, r.tipo_registro
   order by r.no_registro


	if _error <> 0 then
		return _error, trim(_error_desc) || " " || _no_registro;
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
   order by r.no_registro
   
   call sp_par296_cta(_no_registro) returning _error, _error_desc, _msg_cta, _msg_aux,_msg_db,_msg_cr,_msg_ref;
	
	if _error = 0 then
		foreach
			select b.aux_bouquet,sum(abs(a.debito) - abs(a.credito))
			  into _aux_aux, _mto_cobasien
			from tmp0_cta a, emicoase b	
			where a.cuenta = a_cuenta
			  and b.cod_auxiliar = a.cod_auxiliar
              group by b.aux_bouquet
			
			
				if _mto_cobasien is null then
					let _mto_cobasien = 0;
				end if

					
			select sum(abs(a.Db_auxiliar) - abs(a.Cr_auxiliar))			  
			  into  _monto
			 from tmp_aux213c a ,tmp_cglterceros t
			where a.cuenta = a_cuenta
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
				where a.cuenta = a_cuenta
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
				values(	a_cuenta,
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

--reclamos

foreach

	 select r.no_registro,
	        r.tipo_registro
	   into _no_registro,
	        _tipo_registro
	   from sac999:reacomp r, camrecreaco c
	  where r.no_poliza  = c.no_poliza
        and r.no_tranrec = c.no_tranrec
	    and r.tipo_registro = 3
   group by r.no_registro,r.tipo_registro
   order by r.no_registro



	if _error <> 0 then
		return _error, trim(_error_desc) || " " || _no_registro;
	end if



end foreach



--devolucion

foreach

     select r.no_registro,
            r.tipo_registro
	   into _no_registro,
	        _tipo_registro
	   from sac999:reacomp r, camrea c
	  where r.no_poliza = c.no_poliza
	    and r.tipo_registro in(4,5)
   group by r.no_registro,r.tipo_registro
   order by r.no_registro



	if _error <> 0 then
		return _error, trim(_error_desc) || " " || _no_registro;
	end if



end foreach
}
return 0, 'Carga Exitosa';

end
end procedure;