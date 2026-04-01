--**********************************************************
-- Procedimiento que genera el Reporte Mini Convención Miami 2019
--**********************************************************

-- Creado    : 07/01/2019 - Autor: Armando Moreno M.
-- Modificado: 14/01/2019 - Autor: Armando Moreno M.

DROP PROCEDURE sp_pro869a;
CREATE PROCEDURE sp_pro869a()
RETURNING char(50),DEC(16,2),DEC(16,2),char(20),date,date,char(10),DEC(16,2),smallint,char(20),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2);

DEFINE _nombre          CHAR(50); 
DEFINE _tipo_agente     CHAR(1);
define _error           smallint;
define _prima_suscrita	DEC(16,2);
define _prima_sus_ramo  DEC(16,2);
define _cod_agente   	char(5);
define _fecha_aa_ini    date;
define _fecha_aa_fin    date;
define _nombre_tipo,_nombre_tipo2,_nombre_tipo3		char(20);
define _flag_1			smallint;
define _pri_sus_ap      DEC(16,2);
define _prima_salud 	DEC(16,2);
define _prima_cancer 	DEC(16,2);
define _prima_mr    	DEC(16,2);
define _prima_vida   	DEC(16,2);
define _prima_auto, _dif   	DEC(16,2);

--SET DEBUG FILE TO "sp_pro865.trc";
--TRACE ON;

let _error          = 0;
let _prima_suscrita = 0;
let _prima_sus_ramo = 0;
let _pri_sus_ap     = 0;
let _flag_1         = 0;
let _nombre_tipo3 = '';
let _nombre_tipo2 = '';
let _nombre_tipo  = '';
let _prima_salud  = 0;
let _prima_cancer = 0;
let _prima_auto   = 0;
let _prima_vida   = 0;
let _prima_mr     = 0;

SET ISOLATION TO DIRTY READ;

--let _error = sp_pro868a('001','001');  LA CARGA SE PUSO EN PROCEDIMIENTO SP_PRO864 QUE CORRE EN SIS100 QUE ERA DE PORLAMAR

let _fecha_aa_ini = "01/02/2019";
let _fecha_aa_fin = "31/05/2019";

--OPCION A
foreach
	select cod_agente,
		   tipo_agente,
	       tipo_agente2,
	       n_agente,
	       sum(prima_sus_nva),
		   sum(prima_salud),
		   sum(prima_cancer),
           sum(prima_mr),
           sum(prima_vida),
           sum(prima_auto)
	  into _cod_agente,
		   _nombre_tipo,
		   _nombre_tipo2,
		   _nombre,
		   _prima_suscrita,
		   _prima_salud,
		   _prima_cancer,
           _prima_mr,
           _prima_vida,
           _prima_auto
	  from punta_cana
	 where cod_ramo in('018','003','019','002')
     group by tipo_agente, tipo_agente2,cod_agente,n_agente
	 order by tipo_agente, tipo_agente2, sum(prima_sus_nva) desc

	let _dif = 0.00;
	 if _nombre_tipo = 'Grupo I' then
		let _dif = 50000 - _prima_suscrita;
	elif _nombre_tipo = 'Grupo II' then
		let _dif = 40000 - _prima_suscrita;
	elif _nombre_tipo = 'Grupo III' then
		let _dif = 25000 - _prima_suscrita;
	elif _nombre_tipo = 'Grupo IV' then
		let _dif = 20000 - _prima_suscrita;
	elif _nombre_tipo = 'Grupo V' then
		let _dif = 15000 - _prima_suscrita;
	end if
	if _dif < 0 then
		let _dif = 0;
	end if
	if _prima_suscrita = 0 then
		continue foreach;
	end if
    RETURN _nombre,
		   _prima_suscrita,
   		   _prima_sus_ramo,
   		   _nombre_tipo,
		   _fecha_aa_ini,
		   _fecha_aa_fin,
		   _cod_agente,
		   _pri_sus_ap,
		   _flag_1,
		   _nombre_tipo2,
		   _prima_salud,
		   _prima_cancer,
           _prima_mr,
           _prima_vida,
           _prima_auto,
		   _dif
           WITH RESUME;

end foreach
--OPCION B
foreach
	select cod_agente,
		   tipo_agente,
	       tipo_agente3,
	       n_agente,
	       sum(prima_sus_nva),
		   sum(prima_salud),
		   sum(prima_cancer),
           sum(prima_mr),
           sum(prima_vida)
	  into _cod_agente,
		   _nombre_tipo,
		   _nombre_tipo3,
		   _nombre,
		   _prima_suscrita,
		   _prima_salud,
		   _prima_cancer,
           _prima_mr,
           _prima_vida
	  from punta_cana
	 where cod_ramo in('018','003','019')
     group by tipo_agente, tipo_agente3,cod_agente,n_agente
	 order by tipo_agente, tipo_agente3, sum(prima_sus_nva) desc
	 
	if _prima_suscrita = 0 then
		continue foreach;
	end if
	let _dif = 0.00;
	if _nombre_tipo = 'Grupo I' then
		let _dif = 15000 - _prima_suscrita;
	elif _nombre_tipo = 'Grupo II' then
		let _dif = 12000 - _prima_suscrita;
	elif _nombre_tipo = 'Grupo III' then
		let _dif = 9000 - _prima_suscrita;
	elif _nombre_tipo = 'Grupo IV' then
		let _dif = 7000 - _prima_suscrita;
	elif _nombre_tipo = 'Grupo V' then
		let _dif = 5000 - _prima_suscrita;
	end if
	if _dif < 0 then
		let _dif = 0;
	end if

    RETURN _nombre,
		   _prima_suscrita,
   		   _prima_sus_ramo,
   		   _nombre_tipo,
		   _fecha_aa_ini,
		   _fecha_aa_fin,
		   _cod_agente,
		   _pri_sus_ap,
		   _flag_1,
		   _nombre_tipo3,
		   _prima_salud,
		   _prima_cancer,
           _prima_mr,
           _prima_vida,
           0,
		   _dif
           WITH RESUME;

end foreach
END PROCEDURE;