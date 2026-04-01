--Reporte para el Cuadre de las cuentas de Prima Cobrada por Ramo y Auxiliar
--Creado    : 28/12/2015 - Autor: Henry Giron

drop procedure sp_cob780;
create procedure "informix".sp_cob780(
a_periodo1		char(07),
a_periodo2		char(07),
a_tipo          smallint)
returning	integer,
			varchar(100);	

begin

define v_filtros			varchar(255);
define _nom_cuenta			varchar(50);
define v_desc_ramo			varchar(50);
define v_descr_cia			varchar(50);
define _cuenta				char(18);
define _no_poliza			char(10);
define _ano					char(4);
define _cod_tipoprod		char(3);
define _cod_ramo			char(3);
define _prima_cobrada		dec(16,2);
define _prima_suscrita		dec(16,2);
define _monto_total			dec(16,2);
define _diferencia			dec(16,2);
define _saldo				dec(16,2);
define _ramo_sis			smallint;
define _mes					smallint;
define _cod_subramo     	char(3);
define _cod_coasegur		char(3);
define _cod_origen_aseg		char(3);
define _cod_auxiliar		char(5);
define _no_remesa			char(10);
define _renglon				integer;
DEFINE v_aux_terc		    CHAR(5);
define _error				integer;
define _error_desc			varchar(255);
define a_codramo            char(255);
define a_serie              char(255);
define _no_registro         char(10);
define _msg_aux             char(5);
define _msg_db              dec(16,2);
define _msg_cr              dec(16,2);
define _msg_ref             CHAR(10);
define _no_requis			char(10);	

set isolation to dirty read;

let _ano = a_periodo1[1,4];
let _mes = a_periodo1[6,7];
let a_codramo = "001,003,006,008,010,011,012,013,014,021,022;";
let a_serie = "2019,2018,2017,2016,2015,2014,2013,2012,2011,2010,2009,2008;";

--1-Produccion Prima sucrita Facultativo
if a_tipo = 1 then 
	foreach with hold
		select cod_ramo,
			   prima,
			   no_poliza,
			   no_endoso,
               no_factura,
               no_documento			   
		  into _cod_ramo,
			   _prima_suscrita,
			   _no_poliza,
			   _no_endoso,
               _no_requis,
               _no_documento			   
		  from temp_devpri_det
		 where seleccionado = 1
		 order by cod_ramo,no_poliza,no_factura

				foreach
					select no_registro 
					  into _no_registro 
					  from sac999:reacomp
					 where periodo >= a_periodo1 
					   and periodo <= a_periodo2
					   and no_documento = _no_documento
					   and no_remesa = _no_requis
					   and tipo_registro in (4,5)
					   and no_poliza = _no_poliza
					 order by no_endoso desc 
					 
					let _bx_cod_auxiliar = ;
					let _bx_cod_ramo = ;
					let _bx_cod_subramo = ;
					let _bx_cuenta = ;
					let _bx_tipo_comp = ;
					let _bx_no_registro = ;
					let _bx_serie = ;
					let _bx_comision = ;
					let _bx_prima_neta = ;
					let _bx_siniestro = ;
					let _bx_por_pagar = ;
					let _bx_seleccionado = ;				 
					 
					begin
						on exception in(-239,-268)
							update temp_informe
							   set siniestros_pagados = siniestros_pagados + _pagado_neto 
							 where cod_ramo = _cod_ramo
							   and serie  = _serie
							   and relac_inundacion = _relac_inund;
						end exception 	
						let _bx_


						insert into temp_informe (cod_auxiliar,cod_ramo,cod_subramo,cuenta,tipo_comp,no_registro,serie,comision,prima_neta,siniestro,por_pagar,seleccionado)
						values ('999',v_cod_ramo,_cod_subramo,'','1',_serie);
					end
				end foreach
		
	end foreach
end if

--2 Cobros
foreach with hold
     select select a.no_remesa,a.renglon,a.cod_ramo,a.cod_subramo,a.cod_coasegur,sum(a.por_pagar)
	   into _no_remesa,_renglon,_cod_ramo,_cod_subramo,_cod_coasegur,_prima_cobrada
	   from temp_produccion a, temp_det b
	--where no_remesa = '1507628'	and no_poliza = '1273235' --and cuenta = '231010201'
	  where a.seleccionado = 1
        and a.no_remesa = b.no_remesa            
		and a.no_poliza = b.no_poliza            
		and a.renglon = b.renglon
	  group by a.no_remesa,a.renglon,a.cod_ramo,a.cod_subramo,a.cod_coasegur
	 order by a.no_remesa,a.renglon,a.cod_ramo,a.cod_subramo,a.cod_coasegur
	
	
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
	 
	--let _cuenta = sp_sis15("PPRXP", "05", _cod_origen_aseg, _cod_ramo, _cod_subramo);   		
select no_registro
   into _no_registro
   from sac999:reacomp
  where no_poliza = _no_poliza 
    and no_remesa = _no_remesa
	and renglon   = _renglon
    and tipo_registro = 2;	
	
	call sp_par296_cta(_no_registro) returning _error, _error_desc, _msg_aux,_msg_db,_msg_cr,_msg_ref;
	
	if _error = 0 then
	foreach
		select cuenta,
			   cod_auxiliar,
			   sum(debito),
			   sum(credito)
		  into _cuenta,
			   _cod_auxiliar,
			   _debito,
			   _credito
		from tmp0_cta	
		group by 1,2
		
			if _cuenta is null then
				continue foreach;
			end if
			
			let _prima_cobrada = _debito - _credito;
	
			select neto --saldo
			  into _saldo
			  from tmp_saldos
			 where cuenta = _cuenta
			   and tercero = _cod_auxiliar;

			if _saldo is null then
				let _saldo = 0.00;
			end if

			begin
				on exception in(-239,-268)
					update tmp_balance
					   set monto_total = monto_total + _prima_cobrada,
						   diferencia = diferencia + _prima_cobrada
					 where trim(cuenta) = _cuenta
					   and cod_ramo = _cod_ramo
					   and tercero  = _cod_auxiliar;

				end exception
				insert into tmp_balance(
						cuenta,
						cod_ramo,
						monto_total,
						saldo,
						diferencia,
						tercero)
				values(	_cuenta,
						_cod_ramo,
						_prima_cobrada,
						_saldo,
						_saldo + _prima_cobrada,
						_cod_auxiliar);
			end
		end foreach	
    end if					
end foreach

 --3 Reclamos

--4 y 5- Devolucion de Prima
foreach with hold
	select cod_ramo,
		   prima,
		   no_poliza,
           no_documento,
           no_factura		   
	  into _cod_ramo,
		   _prima_suscrita,
		   _no_poliza,
		   _no_documento,
           _no_requis		   
	  from temp_devpri_det
	 where seleccionado = 1
	 order by cod_ramo,no_factura
	
	 select no_registro
	   into _no_registro
	   from sac999:reacomp
	  where no_poliza = _no_poliza 
		and no_documento = _no_documento
		and no_remesa = _no_requis
		and tipo_registro in (4,5);	

	
	call sp_par296_cta(_no_registro) returning _error, _error_desc, _msg_aux,_msg_db,_msg_cr,_msg_ref;
	
	if _error = 0 then
	foreach
		select cuenta,
			   cod_auxiliar,
			   sum(debito),
			   sum(credito)
		  into _cuenta,
			   _cod_auxiliar,
			   _debito,
			   _credito
		from tmp0_cta	
		group by 1,2
		
			if _cuenta is null then
				continue foreach;
			end if
			let _prima_suscrita = debito - credito;
			
			select neto --saldo
			  into _saldo
			  from tmp_saldos
			 where cuenta = _cuenta
			   and tercero = _cod_auxiliar;

			if _saldo is null then
				let _saldo = 0.00;
			end if

			begin
				on exception in(-239,-268)
					update tmp_balance
					   set monto_total = monto_total + _prima_suscrita,
						   diferencia = diferencia + _prima_suscrita
					 where trim(cuenta) = _cuenta
					   and cod_ramo = _cod_ramo
					   and tercero  = _cod_auxiliar;

				end exception
				insert into tmp_balance(
						cuenta,
						cod_ramo,
						monto_total,
						saldo,
						diferencia,
						tercero)
				values(	_cuenta,
						_cod_ramo,
						_prima_suscrita,
						_saldo,
						_saldo + _prima_suscrita,
						_cod_auxiliar);
			end
			
		end foreach	
    end if		
	
end foreach

foreach
	select cuenta,
	       tercero,
		   cod_ramo,
		   monto_total,
		   saldo,
		   diferencia
	  into _cuenta,
	       _cod_auxiliar,
		   _cod_ramo,
		   _monto_total,
		   _saldo,
		   _diferencia
	  from tmp_balance

		select nombre
		  into v_desc_ramo
		  from prdramo
		 where cod_ramo = _cod_ramo;

	select nombre
	  into _nom_cuenta
	  from tmp_saldos
	 where cuenta = _cuenta
	 and tercero = _cod_auxiliar;

	return	v_descr_cia,
			_nom_cuenta,
			_cuenta,
			_cod_ramo,
			v_desc_ramo,
			_monto_total,
			_saldo,
			_diferencia, _cod_auxiliar with resume;
end foreach



end

end procedure;