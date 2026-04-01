--Reporte para el Cuadre de las cuentas de Prima Cobrada por Ramo y Auxiliar
--Creado    : 28/12/2015 - Autor: Henry Giron

drop procedure sp_cob779;
create procedure "informix".sp_cob779(
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
DEFINE v_aux_terc		  CHAR(5);

set isolation to dirty read;

let _prima_cobrada  = 0;
let _monto_total      = 0;

let v_descr_cia = sp_sis01(a_compania);

drop table if exists tmp_balance;
drop table if exists tmp_saldos;
drop table if exists temp_det;

--Tabla Maestra del Procedimiento
create temp table tmp_balance(
cuenta		char(12),
cod_ramo	char(3)   not null,
monto_total	dec(16,2) not null,
saldo		dec(16,2),
diferencia	dec(16,2),
primary key (cuenta,cod_ramo)) with no log;

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
--Procedure de Generación de Primas Suscrita para el periodo dado.
call sp_pr860f('001','001',a_periodo1,a_periodo2,"*","*","*","*","001,003,005;","*","2019,2018,2017,2016,2015,2014,2013,2012,2011,2010,2009,2008;","01","*")
returning v_filtros;

--execute procedure sp_sac42(_ano, _mes, a_nivel, a_db);
execute procedure sp_sac42_aux('01','*','*',_ano,_mes,a_db) ;

foreach with hold
	select no_remesa,renglon,cod_ramo,cod_subramo,cod_coasegur,sum(por_pagar)
	  into _no_remesa,_renglon,_cod_ramo,_cod_subramo,_cod_coasegur,_prima_cobrada
	from temp_produccion
	where no_remesa = '1507628'	and no_poliza = '1273235' --and cuenta = '231010201'
	group by no_remesa,renglon,cod_ramo,cod_subramo,cod_coasegur
	order by no_remesa,renglon,cod_ramo,cod_subramo,cod_coasegur
	
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
	
	if _cuenta is null then
		continue foreach;
	end if
	
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

drop table if exists temp_det;
end

end procedure;