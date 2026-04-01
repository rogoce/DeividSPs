-- Reporte de los Bonificacion de Rentabilidad 2011 
-- Creado    : 24/02/2011 - Autor: Henry Giron  
-- Modificado: 24/02/2011 - Autor: Henry Giron  
-- Modificado: 03/02/2012 - Autor: Henry para tomar valor desde 2011-12 la tabla rentabilidad1. 

--DROP PROCEDURE sp_che95asimf;
CREATE PROCEDURE sp_che95asimf(a_cia CHAR(3),a_cod_agente CHAR(5) default "*",a_periodo char(7))
RETURNING CHAR(50),CHAR(100), CHAR(100),DEC(16,2),CHAR(50),DEC(16,2),DEC(16,2),DEC(16,2),DEC(16,2),CHAR(7),smallint; 

-- cia
-- agente
-- categoria
-- susc_minima	 
-- nombre_ramo
-- prima_ant
-- prima_act
-- crecimiento
-- porc_crecimiento

DEFINE v_nombre_cia      CHAR(50);
DEFINE _TotProdAnt       DEC(16,2);
DEFINE _TotProdAct       DEC(16,2);
DEFINE _cod_agente       CHAR(5);  
DEFINE _n_agente         CHAR(50); 
DEFINE _nombre_agente    CHAR(100); 
DEFINE _cod_tipo		 CHAR(3);
DEFINE _nombre_tipo      CHAR(50);
DEFINE _nombre_ramo      CHAR(50);
DEFINE _ProdAntRam       DEC(16,2);
DEFINE _ProdActRam       DEC(16,2);
DEFINE _ProducMin        DEC(16,2);
DEFINE _crecimiento		 DEC(16,2);
DEFINE _Porc_crec    	 DEC(16,2);
DEFINE _estatus_licencia CHAR(1);
DEFINE _periodo2         CHAR(7);
DEFINE _cre_min          smallint;

--SET DEBUG FILE TO "che95a.trc";
--TRACE ON;
--DROP TABLE tmpche95a ;

SET ISOLATION TO DIRTY READ;

CREATE TEMP TABLE tmpche95a
	(cia                CHAR(50),
	agente				CHAR(100),
	categoria			CHAR(100),
	susc_minima			DEC(16,2),
	nombre_ramo			CHAR(50),
	prima_ant			DEC(16,2),
	prima_act			DEC(16,2),
	crecimiento			DEC(16,2),
	porc_crecimiento	DEC(16,2),
	cre_min             smallint)
	WITH NO LOG;

CREATE TEMP TABLE chqrenta030212a
	(cia                CHAR(50),
	periodo             CHAR(7),
	no_documento        CHAR(20),
	cod_agente          CHAR(5),
	n_agente			CHAR(100),
	tipo                CHAR(3),
	categoria			CHAR(100),
	nombre_ramo			CHAR(50),
	pri_sus_pag_ap		DEC(16,2),
	pri_sus_pag_aa		DEC(16,2))
	WITH NO LOG;

let v_nombre_cia = sp_sis01(a_cia); 
let _crecimiento = 0;
let _Porc_crec   = 100;

if trim(a_periodo) >= "2021-12" then

	insert into chqrenta030212a(
		   cia,             
		   periodo,          
		   no_documento,     
		   cod_agente,       
		   n_agente,			
		   tipo,             		
		   nombre_ramo,			
		   pri_sus_pag_ap,		
		   pri_sus_pag_aa)		
	select v_nombre_cia,
	       periodo,
		   trim(no_documento),
	       trim(cod_agente),
	       trim(n_agente),
	       trim(tipo),
		   trim(nombre_ramo),
	       pri_susc_ap,
	       pri_susc_aa
	  from rentabilidad11
	 where periodo  = a_periodo
       and monto_90 = 0; 
else
	insert into chqrenta030212a(
		   cia,             
		   periodo,          
		   no_documento,     
		   cod_agente,       
		   n_agente,			
		   tipo,             		
		   nombre_ramo,			
		   pri_sus_pag_ap,		
		   pri_sus_pag_aa)		
	select v_nombre_cia,
	       periodo,
		   trim(no_documento),
	       trim(cod_agente),
	       trim(n_agente),
	       trim(tipo),
		   trim(nombre_ramo),
	       pri_sus_pag_ap,
	       pri_sus_pag_aa
	  from chqrenta
	 where periodo = a_periodo;

end if

FOREACH
	select trim(cod_agente),
	       trim(n_agente),
	       tipo,
	       sum(pri_sus_pag_ap),
	       sum(pri_sus_pag_aa) 
	  into _cod_agente,
	       _n_agente,
	       _cod_tipo,
		   _TotProdAnt,  
		   _TotProdAct 
	  from chqrenta030212a 
	 where periodo = a_periodo
	   and cod_agente matches a_cod_agente
     group by 1,2,3
	 order by 1,2,3,4 desc

	if  _TotProdAnt is null or _TotProdAnt = 0 then
		let _TotProdAnt = 0;
	end if
	if  _TotProdAct is null or _TotProdAct = 0 then
		let _TotProdAct = 0;
	end if
	let _nombre_agente = trim(_n_agente)||" "||_cod_agente;
	select estatus_licencia into _estatus_licencia from agtagent where cod_agente = _cod_agente;
	if trim(_estatus_licencia) <> "A" then
		let _nombre_agente = "* " || trim(_n_agente)||" "||_cod_agente;
	end if

	let _cre_min = 0;
	if a_periodo >= "2011-12" then

		select trim(name_tipo),prim_suscrita_min,crecimiento_min
		  into _nombre_tipo,_ProducMin,_cre_min
		  from prdrenttipo 
		 where periodo  = a_periodo
		   and cod_tipo = _cod_tipo 
		   and activo   = 1 ;

	else

		if  _cod_tipo = 'A' then 
			let _nombre_tipo = 'AUTOMOVIL';
			let _ProducMin = 25000;
		end if
		if  _cod_tipo = 'C' then 
			let _nombre_tipo = 'PATRIMONIAL';
			let _ProducMin = 15000;
		end if
		if  _cod_tipo = 'D' then 
			let _nombre_tipo = 'PERSONAS';
			let _ProducMin = 15000;
		end if

	end if

	FOREACH
		select nombre_ramo,
			   sum(pri_sus_pag_ap),
			   sum(pri_sus_pag_aa) 
		  into _nombre_ramo,
			   _ProdAntRam, 
			   _ProdActRam 
		  from chqrenta030212a 
		 where periodo = a_periodo
		   and cod_agente matches a_cod_agente
		   and tipo = _cod_tipo
		 group by 1
		 order by 1,2

		if  _ProdAntRam is null or _ProdAntRam <= 0 then
			let _crecimiento = _ProdActRam;
			let _Porc_crec   = 1;
		else
			let _crecimiento = _ProdActRam - _ProdAntRam;
			let _Porc_crec   = _crecimiento / _ProdAntRam;
		end if

		insert into tmpche95a(cia,agente,categoria,susc_minima,nombre_ramo,prima_ant,prima_act,crecimiento,porc_crecimiento,cre_min)
		values (v_nombre_cia,_nombre_agente,_nombre_tipo,_ProducMin,_nombre_ramo,_ProdAntRam,_ProdActRam,_crecimiento,_Porc_crec,_cre_min );

	END FOREACH
END FOREACH

select agt_per_fidel into _periodo2 from parparam;
if a_periodo[1,4] < _periodo2[1,4] then
	let _periodo2 = a_periodo;
end if

FOREACH
	select cia,agente,categoria,susc_minima,nombre_ramo,prima_ant,prima_act,crecimiento,porc_crecimiento,cre_min 
	  into v_nombre_cia,_nombre_agente,_nombre_tipo,_ProducMin,_nombre_ramo,_ProdAntRam,_ProdActRam,_crecimiento,_Porc_crec,_cre_min
	  from tmpche95a 
	 order by 1,2,3,5

	RETURN v_nombre_cia,
	       _nombre_agente,
	       _nombre_tipo,
	       _ProducMin,
	       _nombre_ramo,
	       _ProdAntRam,
	       _ProdActRam,
	       _crecimiento,
	       _Porc_crec,
		   _periodo2,
		   _cre_min
		   WITH RESUME;	
	
END FOREACH
DROP TABLE tmpche95a;
DROP TABLE chqrenta030212a;
END PROCEDURE;  
