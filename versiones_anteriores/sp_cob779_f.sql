--Reporte para el Cuadre de las cuentas de Prima Cobrada por Ramo y Auxiliar
--Creado    : 28/12/2015 - Autor: Henry Giron

drop procedure sp_cob779_f;
create procedure "informix".sp_cob779_f(
a_compania		char(03),
a_agencia		char(03),
a_periodo1		char(07),
a_periodo2		char(07),
a_nivel			smallint,
a_db			char(18))
returning	varchar(50)	as compania,
			varchar(50)	as nom_cuenta,
			char(18)	as cuenta,			
			char(3)		as cod_ramo,
			varchar(50)	as nom_ramo,
			dec(16,2)	as monto_tecnico,
			dec(16,2)	as saldo,
			dec(16,2)	as diferencia,
			char(5)     as tercero;

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

let _prima_cobrada  = 0;
let _monto_total      = 0;

let v_descr_cia = sp_sis01(a_compania);

drop table if exists tmp_balance;
drop table if exists tmp_saldos;
drop table if exists temp_det;
drop table if exists tmp_producion_ps;
drop table if exists temp_ps;
drop table if exists temp_ps_det;

--Tabla Maestra del Procedimiento
create temp table tmp_balance(
cuenta		char(12),
cod_ramo	char(3)   not null,
monto_total	dec(16,2) not null,
saldo		dec(16,2),
diferencia	dec(16,2),
tercero		char(5),
primary key (cuenta,cod_ramo,tercero)) with no log;

--Tabla para el proceso de saldos por cuenta.
{create temp table tmp_saldos(
cuenta		char(12),
nombre		char(50),
debito		dec(16,2),
credito		dec(16,2),
saldo		dec(16,2),
saldo_ant	dec(16,2),
saldo_act	dec(16,2),
referencia	char(20)) with no log;}

let _ano = a_periodo1[1,4];
let _mes = a_periodo1[6,7];
let a_codramo = "001,003,006,008,010,011,012,013,014,021,022;";
let a_serie = "2019,2018,2017,2016,2015,2014,2013,2012,2011,2010,2009,2008;";

--Procedure de Generacion de Primas Suscrita Facultativo para el periodo dado.
call sp_pr123a('001','001',a_periodo1,a_periodo2,"*","*","*","*",a_codramo,"*","*",a_serie,0)
returning _error, _error_desc;
if _error <> 0 then
	return v_descr_cia,
			'',
			'',
			'',
			_error_desc,
			0.00,
			0.00,
			_error,
			'';	
end if

	select * 
	  from tmp_producion_ps
	  into temp temp_ps;
	  
	select * 
	  from temp_det
	  into temp temp_ps_det;	 

--Procedure de Generacion de Primas Cobrada para el periodo dado.
call sp_pr860f('001','001',a_periodo1,a_periodo2,"*","*","*","*",a_codramo,"*",a_serie,"01","*")
returning _error, _error_desc;
if _error <> 0 then
	return v_descr_cia,
			'',
			'',
			'',
			_error_desc,
			0.00,
			0.00,
			_error,
			'';	
end if

--execute procedure sp_sac42(_ano, _mes, a_nivel, a_db);
call sp_sac42_aux('01','*','*',_ano,_mes,a_db) returning _error, _error_desc;
if _error <> 0 then
	return v_descr_cia,
			'',
			'',
			'',
			_error_desc,
			0.00,
			0.00,
			_error,
			'';
	--'Cuadre Contable, Error: ' || trim(_error_desc),'',a_cuenta,'',0.00,0.00,0.00,_error,'',0,'','','','','','';
end if

--1-Produccion Prima sucrita Facultativo
foreach with hold
	select cod_ramo,
		   prima,
		   no_poliza,
           no_endoso		   
	  into _cod_ramo,
		   _prima_suscrita,
		   _no_poliza,
		   _no_endoso		   
	  from temp_ps_det
	 where seleccionado = 1
	 order by cod_ramo,no_factura

	select ramo_sis
	  into _ramo_sis
	  from prdramo
	 where cod_ramo = _cod_ramo;

	if _ramo_sis = 1 then
		let _cod_ramo = '002';
	end if

	if _cod_ramo in ('007') then --Vidrios se contabiliza en la cuenta de riesgos diversos
		let _cod_ramo = '015';
	elif _cod_ramo in ('003','021') then --Multiriesgo y TodoRiesgo se contabiliza en Incendio
		let _cod_ramo = '001';
	elif _cod_ramo in ('010','011','012','013','014','022') then	--Ramos Técnicos
		let _cod_ramo = '099';
	end if
	
 select no_registro
   into _no_registro
   from sac999:reacomp
  where no_poliza = _no_poliza 
    and no_endoso = _no_endoso
    and tipo_registro = 1;	

	
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