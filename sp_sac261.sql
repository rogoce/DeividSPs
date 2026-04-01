drop procedure sp_sac261;
create procedure sp_sac261(a_periodo char(7))
returning char(20),
          char(50),
          char(50),
		  date,
		  date,
		  varchar(50),
		  varchar(50),
		  char(30),
		  varchar(50),
		  varchar(50),
		  char(30),
		  char(1),
		  date,
		  dec(16,2),
		  char(2),
		  char(27),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  char(10),
		  char(7);
		  
define _cuenta		char(30);
define _grupo		char(3);
define _no_poliza,_origen   char(10);
define _debito		dec(16,2);
define _credito,_moros_precovid		dec(16,2);
define _cnt         int;
define _no_tranrec  char(10);
define _cod_subramo char(3);
define _saldo    dec(16,2);
define _corriente_pxc,_monto30_pxc,_monto60_pxc    dec(16,2);
define _saldo_pxc,_exigible_pxc,_monto120_pxc,_saldo_neto_pxc  dec(16,2);
define _impuesto_pxc,_monto150_pxc    dec(16,2);
define _por_vencer_pxc,_monto90_pxc,_monto180_pxc    dec(16,2);
define _mto_ult_pago  dec(16,2);
define _no_registro     char(10);
define _n_grupo,_n_cliente      varchar(50);
define _periodo char(7);
define _tipo_prod       char(27);
define _estatus_char,_cedula    char(30);
define _tipo_persona char(1);
define _no_documento    char(20);
define _estado char(2);
define _n_ramo,_n_subramo,_n_corredor,_n_forma_pago        varchar(50);
define _vig_ini,_vig_fin,_fecha_ult_pago         date;

--SET DEBUG FILE TO "sp_sac261.trc";
--TRACE ON;


set isolation to dirty read;

let _cnt = 0;

foreach
	SELECT emipomae.no_documento,
		   ram.nombre,
		   sub.nombre as subramo,
		   emipomae.vigencia_inic,
		   emipomae.vigencia_final,
		   agtagent.nombre,
		   cobforpa.nombre,
		   case emipomae.estatus_poliza
			when 1 then '1 - Vigentes'
			when 2 then '2 - Canceladas'
			when 3 then '3 - Vencidas'
			when 4 then '4 - Anuladas'
			else '5 - Otros estatus'
		   end,
		  cligrupo.nombre,
		  cliclien.nombre,
		  cliclien.cedula,
		  cliclien.tipo_persona,
		  cobmoros.fecha_ult_pago,
		  sum(cobmoros.monto_ult_pago*emipoagt.porc_partic_agt/100) as monto_ult_pago,
		  case emipomae.cod_grupo
			when '00000' then 'Si'
			when '1000' then 'Si'
			else 'No'
		  end,
		  case emipomae.cod_tipoprod
			when '001' then '001 - Coaseguro Mayoritario'
			when '002' then '002 - Coaseguro Minoritario'
			when '004' then '004 - Reaseguro Asumido'
			when '005' then '005 - Produccion Directa'
		  end,
		  sum(cobmoros.saldo*emipoagt.porc_partic_agt/100) as saldo,
		  sum(cobmoros.saldo_pxc*emipoagt.porc_partic_agt/100) as saldo_pxc,
		  sum(cobmoros.impuesto_pxc*emipoagt.porc_partic_agt/100) as impuesto_pxc,
		  sum(cobmoros.por_vencer_pxc*emipoagt.porc_partic_agt/100)as por_vencer_pxc,
		  sum(cobmoros.exigible*emipoagt.porc_partic_agt/100)as exigible_pxc,
		  sum(cobmoros.corriente_pxc*emipoagt.porc_partic_agt/100)as corriente_pxc,
		  sum(cobmoros.monto_30_pxc*emipoagt.porc_partic_agt/100) as monto30_pxc,
		  sum(cobmoros.monto_60_pxc*emipoagt.porc_partic_agt/100) as monto60_pxc,
		  sum(cobmoros.monto_90_pxc*emipoagt.porc_partic_agt/100) as monto90_pxc,
		  sum(cobmoros.dias_120_pxc*emipoagt.porc_partic_agt/100) as monto120_pxc,
		  sum(cobmoros.dias_150_pxc*emipoagt.porc_partic_agt/100) as monto150_pxc,
		  sum(cobmoros.dias_180_pxc*emipoagt.porc_partic_agt/100) as monto180_pxc,
		  sum(cobmoros.saldo_neto*emipoagt.porc_partic_agt/100) as saldo_neto_pxc,
		  sum(corte.monto_pxc*emipoagt.porc_partic_agt/100) as moros_precovid,
		  case emipomae.cod_origen
			when '001' then 'Local'
			when '002' then 'Exterior'
		  end,
		  cobmoros.periodo
	 into _no_documento,
	      _n_ramo,
		  _n_subramo,
		  _vig_ini,
		  _vig_fin,
		  _n_corredor,
		  _n_forma_pago,
		  _estatus_char,
		  _n_grupo,
		  _n_cliente,
		  _cedula,
		  _tipo_persona,
		  _fecha_ult_pago,
		  _mto_ult_pago,
		  _estado,
		  _tipo_prod,
		  _saldo,
		  _saldo_pxc,
		  _impuesto_pxc,
		  _por_vencer_pxc,
		  _exigible_pxc,
		  _corriente_pxc,
		  _monto30_pxc,
		  _monto60_pxc,
		  _monto90_pxc,
		  _monto120_pxc,
		  _monto150_pxc,
		  _monto180_pxc,
		  _saldo_neto_pxc,
		  _moros_precovid,
		  _origen,
		  _periodo
	 FROM deivid_cob:cobmoros2 cobmoros
		inner join emipomae
		on emipomae.no_poliza = cobmoros.no_poliza
		and cobmoros.periodo  = a_periodo
		inner join prdramo ram
		on emipomae.cod_ramo = ram.cod_ramo
		inner join prdsubra sub
		on sub.cod_ramo = emipomae.cod_ramo
		and sub.cod_subramo = emipomae.cod_subramo
		inner join cliclien
		on cliclien.cod_cliente=emipomae.cod_contratante
		inner join cligrupo
		on cligrupo.cod_grupo=emipomae.cod_grupo
		inner join emipoagt
		on emipomae.no_poliza=emipoagt.no_poliza
		inner join agtagent
		on agtagent.cod_agente=emipoagt.cod_agente
		inner join cobforpa
		on emipomae.cod_formapag=cobforpa.cod_formapag
		left join morosidad_precovid corte
		on corte.no_documento = cobmoros.no_documento
		GROUP BY ram.nombre,cliclien.nombre,emipomae.no_documento,emipomae.vigencia_inic,emipomae.vigencia_final,
		emipomae.cod_origen,cobmoros.periodo,emipomae.cod_grupo,cobforpa.nombre,emipomae.cod_tipoprod,agtagent.nombre,
		emipomae.estatus_poliza,cligrupo.nombre,cliclien.cedula,cobmoros.fecha_ult_pago,subramo,cliclien.tipo_persona
		HAVING sum(cobmoros.saldo * emipoagt.porc_partic_agt/100) <> 0
		
	return _no_documento,_n_ramo,_n_subramo,_vig_ini,_vig_fin,_n_corredor,_n_forma_pago,_estatus_char,_n_grupo,
	          _n_cliente,_cedula,_tipo_persona,_fecha_ult_pago,_mto_ult_pago,_estado,_tipo_prod,_saldo,_saldo_pxc,
	          _impuesto_pxc,_por_vencer_pxc,_exigible_pxc,_corriente_pxc,_monto30_pxc,_monto60_pxc,_monto90_pxc,
	          _monto120_pxc,_monto150_pxc,_monto180_pxc,_saldo_neto_pxc,_moros_precovid,_origen,_periodo with resume;
	
end foreach
end procedure
