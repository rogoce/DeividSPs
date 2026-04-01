-- Procedimiento que carga los datos para el acuerdo bono de participacion de utilidades
 
-- Creado     :	04/03/2015 - Autor: Federico Coronado

-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_rep03;		

create procedure "informix".sp_rep03()
returning varchar(10), 
          varchar(30),
          varchar(3),
          varchar(30),
          dec(10,2),
          dec(10,2),
          dec(10,2),
		  dec(10,2);

define _cod_agente    			varchar(10);
define _nombre_agente  			varchar(30);
define _cod_ramo				varchar(3);
define _ramo_nombre             varchar(30);
define _prima_devengada         dec(10,2);
define _incurrido_bruto         dec(10,2);
define _saldo_90                dec(10,2);
define _polizas_renov_aa        smallint;
define _polizas_ap              smallint;
define _polizas_renov_ap        smallint;
define _persistencia            dec(10,2);
define _total_polizas_pasado    dec(10,2);


foreach
	select cod_agente, 
	       nombre_agente,
		   cod_ramo,
		   ramo_nombre,
		   sum(prima_devengada),
		   sum(incurrido_bruto),
		   sum(saldo_90),
		   sum(polizas_renov_aa),
		   sum(polizas_ap),
		   sum(polizas_renov_ap)
	 into _cod_agente,
		  _nombre_agente,
		  _cod_ramo,
		  _ramo_nombre,
		  _prima_devengada,
		  _incurrido_bruto,
		  _saldo_90,
		  _polizas_renov_aa,
		  _polizas_ap,
		  _polizas_renov_ap
	  from tmp_utilidades_doc
  group by 1,2,3,4
  order by 2,4
  
		if _polizas_renov_aa is null then
			let _polizas_renov_aa =0.00;
		end if

		if _polizas_ap is null then
			let _polizas_ap =0.00;
		end if		

		if _polizas_renov_ap is null then
			let _polizas_renov_ap =0.00;
		end if		

		let _total_polizas_pasado = _polizas_ap + _polizas_renov_ap;
		
		if _total_polizas_pasado > 0 then
			let _persistencia = (_polizas_renov_aa / (_total_polizas_pasado)) * 100;
		else
			let _persistencia = 0.00;
		end if

return _cod_agente,
       _nombre_agente,
	   _cod_ramo,
	   _ramo_nombre,
	   _prima_devengada,
	   _incurrido_bruto,
	   _saldo_90,
	   _persistencia
	   with resume;
end foreach
end procedure