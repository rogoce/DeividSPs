-- Monitoreo de las Remesas para Verificar errores en las comisiones
-- 
-- Creado    : 22/06/2004 - Autor: Demetrio Hurtado Almanza 
--

drop procedure sp_cob149_amm;
create procedure sp_cob149_amm(a_periodo char(7))
returning char(10),
          integer,
		  char(50),
		  char(50),
		  char(50);

define _no_remesa,_no_poliza_ant	char(10);
define _renglon		integer;
define _porc_partic	dec(16,2);

define _no_poliza	char(10);
define _cod_agente,_cod_agt	char(5);
define _cantidad	smallint;
define _fecha		date;

define _nombre1		char(50);
define _nombre2		char(50);

let _nombre1 = "";
let _nombre2 = "";

foreach
	select cob.no_remesa,cob.renglon,cob.no_poliza,ant.no_poliza			-- as no_poliza_ant,'02904' as cod_agente_ant
	into _no_remesa,_renglon,_no_poliza,_no_poliza_ant
	from cobredet cob
	inner join cobreagt agt on agt.no_remesa = cob.no_remesa and agt.renglon = cob.renglon
	inner join emipomae emi on emi.no_poliza = cob.no_poliza
	inner join emipomae ant on emi.no_documento = ant.no_documento and ant.vigencia_final = emi.vigencia_inic
	where cob.no_remesa = '2141825'
	and agt.cod_Agente = '03250'

	update cobredet
	  set no_poliza  = _no_poliza_ant
	 where no_remesa = _no_remesa
	   and renglon   = _renglon;

	update cobreagt
	   set cod_agente = '02904'
	 where no_remesa  = _no_remesa
	   and renglon    = _renglon;
	   
end foreach

return "0", 0, "Verificacion Completada ...", "", "";

end procedure