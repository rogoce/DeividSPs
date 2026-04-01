--********************************************************
-- Procedimiento que Carga las Bonificaciones de cobranza 2010
--********************************************************

-- Creado    : 27/02/2008 - Autor: Armando Moreno M.
-- Modificado: 27/02/2008 - Autor: Armando Moreno M.

-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_verifica;

CREATE PROCEDURE sp_verifica(a_no_reg char(10))
RETURNING integer;

DEFINE _cod_agente      CHAR(5);  
DEFINE _no_poliza       CHAR(10);
define _cod_subramo     char(3); 
define _cod_origen      char(3); 
DEFINE _no_remesa       CHAR(10); 
DEFINE _renglon         SMALLINT; 
DEFINE _monto           DEC(16,2);
DEFINE _no_recibo       CHAR(10); 
DEFINE _fecha           DATE;     
DEFINE _prima           DEC(16,2);
DEFINE _porc_partic     DEC(5,2); 
DEFINE _porc_comis      DEC(5,2);
DEFINE _porc_comis2     DEC(5,2);
DEFINE _porc_coas_ancon DEC(5,2);
DEFINE _sobrecomision   DEC(16,2);
DEFINE _nombre          CHAR(50);
DEFINE _no_documento    CHAR(20); 
DEFINE _no_requis       CHAR(10); 
DEFINE _cod_tipoprod    CHAR(3);  
DEFINE _tipo_prod       SMALLINT; 
DEFINE _monto_vida      DEC(16,2);
DEFINE _monto_danos     DEC(16,2);
DEFINE _monto_fianza    DEC(16,2);
DEFINE _cod_tiporamo    CHAR(3);  
DEFINE _tipo_ramo       SMALLINT; 
DEFINE _cod_ramo        CHAR(3);  
DEFINE _no_licencia     CHAR(10); 
DEFINE _tipo_mov        CHAR(1);  
DEFINE _incobrable		SMALLINT;
DEFINE _tipo_pago     	SMALLINT;
DEFINE _tipo_agente     CHAR(1);
DEFINE _cod_producto	char(5);
DEFINE _cod_formapag    char(3);
DEFINE _tipo_forma      SMALLINT;
DEFINE _no_licencia2    CHAR(10); 
DEFINE _nombre2         CHAR(50); 
define _forma_pag		smallint;
define _fecha_hoy       date;
DEFINE v_prima_orig     DEC(16,2);
DEFINE v_saldo          DEC(16,2);
DEFINE v_por_vencer     DEC(16,2);
DEFINE v_exigible       DEC(16,2);
DEFINE v_corriente      DEC(16,2);
DEFINE v_monto_30       DEC(16,2);
DEFINE v_monto_60       DEC(16,2);
define _prima_45        DEC(16,2);
define _prima_90		DEC(16,2);
define _prima_r  		DEC(16,2);
define _prima_rr  		DEC(16,2);
define _formula_a  		DEC(16,2);
define _cnt             integer;
define v_monto_30bk		DEC(16,2);
define v_corr			DEC(16,2);
DEFINE _formula_b       DEC(16,2);
define _comision1       DEC(16,2);
define _comision2       DEC(16,2);
define _prima_bruta     DEC(16,2);
define _cod_grupo       char(5);
define _cedula_agt      char(30);				   
define _cedula_paga		char(30);				   
define _cedula_cont		char(30);				   
define _cod_pagador     char(10);				   
define _cod_contratante char(10);				   
define _estatus_licencia char(1);				   
define v_nombre_clte     char(100);				   
define _cod_contr        char(10);
define _error           smallint;				   
define _monto_m			DEC(16,2);				   
define _comision		DEC(16,2);				   
define _suc_origen      char(3);				   
define _beneficios      smallint;				   
define _contado         smallint;				   
define _dias            integer;
define _fecha_decla     date;
define _mess            integer;
define _anno            integer;
define _f_ult           date;
define _f_decla_ult     date;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _concurso        smallint;
define _no_cuenta       char(17);


SET ISOLATION TO DIRTY READ;


{foreach

	SELECT cod_agente
	  INTO _cod_agente
	  FROM chqboni
     WHERE periodo = '2010-01'
	 GROUP BY cod_agente
	 ORDER BY cod_agente

	SELECT SUM(comision)
	  INTO _comision
	  FROM chqboni
	 WHERE cod_agente = _cod_agente
	   AND periodo    = '2010-01';

		INSERT INTO chqbosal(
		cod_agente,
		saldo_ini,
		saldo_act,
		periodo
		)
		VALUES (
		_cod_agente,
		_comision / 2,
		_comision / 2,
		'2010-01'
		);

end foreach	}

select * 
  from emiredis
 where cod_sucursal = '001'
   and usuario = 'GALEMAN'
  into temp prueba;

update prueba
   set cod_sucursal = a_no_reg;

insert into emiredis
select * 
  from prueba;

drop table prueba;

{foreach

	select no_documento,
	       no_cuenta
	  into _no_documento,
	       _no_cuenta
	  from cobcutmp
	 where rechazado = 1

	 select max(fecha)
	   into _f_ult
	   from cobredet
	  where doc_remesa = _no_documento
		and actualizado  = 1
		and tipo_mov	 in ("P", "N");

	  return _no_documento,_f_ult,_no_cuenta with resume;

end foreach	

select * 
  from cobredet
 where no_remesa = '320640'
   and renglon between 2 and 17
  into temp prueba;

update prueba
   set no_remesa = '375122';


insert into cobredet
select * from prueba;


drop table prueba; }

{select * 
  from sac999:reacompasie_dbs
 where no_registro = a_no_reg
  into temp prueba;

delete from sac999:reacompasie
 where no_registro = a_no_reg;


insert into sac999:reacompasie
select * from prueba;

drop table prueba;

---------------------------------

select * 
  from sac999:reacompasiau_dbs
 where no_registro = a_no_reg
  into temp prueba;

delete from sac999:reacompasiau
 where no_registro = a_no_reg;


insert into sac999:reacompasiau
select * from prueba;

drop table prueba;}

return 0; 

END PROCEDURE;