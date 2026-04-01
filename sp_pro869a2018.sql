--**********************************************************
-- Procedimiento que genera el Reporte Mini Convención 2018
--**********************************************************

-- Creado    : 30/01/2017 - Autor: Armando Moreno M.
-- Modificado: 10/02/2017 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_pro869a;
CREATE PROCEDURE sp_pro869a()
RETURNING char(50),DEC(16,2),DEC(16,2),char(20),date,date,char(10),DEC(16,2),smallint;

DEFINE _nombre          CHAR(50); 
DEFINE _tipo_agente     CHAR(1);
define _error           smallint;
define _prima_suscrita	DEC(16,2);
define _prima_sus_ramo  DEC(16,2);
define _cod_agente   	char(5);
define _fecha_aa_ini    date;
define _fecha_aa_fin    date;
define _nombre_tipo		char(20);
define _flag_1			smallint;
define _pri_sus_ap      DEC(16,2);

--SET DEBUG FILE TO "sp_pro865.trc";
--TRACE ON;

let _error          = 0;
let _prima_suscrita = 0;
let _prima_sus_ramo = 0;
let _pri_sus_ap     = 0;
let _flag_1         = 0;

SET ISOLATION TO DIRTY READ;

--let _error = sp_pro868a('001','001');  LA CARGA SE PUSO EN PROCEDIMIENTO SP_PRO864 QUE CORRE EN SIS100 QUE ERA DE PORLAMAR

let _fecha_aa_ini = "01/03/2018";
let _fecha_aa_fin = "30/06/2018";

foreach
	select cod_agente,
		   tipo_agente,
		   n_agente,
		   sum(prima_sus_nva),
		   sum(prima_cobrada)        -- prima suscrita 2017
	  into _cod_agente,
		   _nombre_tipo,
		   _nombre,
		   _prima_suscrita,
		   _pri_sus_ap
	  from punta_cana
	 group by tipo_agente,cod_agente,n_agente
	 order by tipo_agente,cod_agente,n_agente

  	select sum(prima_sus_nva)
	  into _prima_sus_ramo
	  from punta_cana
	 where cod_agente = _cod_agente
	   and cod_ramo in('018','003','019');
	   
	if _prima_sus_ramo is null then
		let _prima_sus_ramo = 0.00;
	end if
	
	let _flag_1 = 0;
	if _nombre_tipo = 'Grupo I' and _prima_suscrita >= 50000 and _prima_sus_ramo >= 10000 then
		let _flag_1 = 1;
	elif _nombre_tipo = 'Grupo II' and _prima_suscrita >= 40000 and _prima_sus_ramo >= 8000 then
		let _flag_1 = 1;
	elif _nombre_tipo = 'Grupo III' and _prima_suscrita >= 25000 and _prima_sus_ramo >= 5000 then
		let _flag_1 = 1;
	elif _nombre_tipo = 'Grupo IV' and _prima_suscrita >= 15000 and _prima_sus_ramo >= 3000 then
		let _flag_1 = 1;
	elif _nombre_tipo = 'Grupo V' and _prima_suscrita >= 10000 and _prima_sus_ramo >= 2000 then
		let _flag_1 = 1;
	end if	
	
    RETURN _nombre,
		   _prima_suscrita,
   		   _prima_sus_ramo,
   		   _nombre_tipo,
		   _fecha_aa_ini,
		   _fecha_aa_fin,
		   _cod_agente,
		   _pri_sus_ap,
		   _flag_1
           WITH RESUME;

end foreach
END PROCEDURE;