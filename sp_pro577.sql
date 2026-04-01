   DROP procedure sp_pro577;
   CREATE procedure "informix".sp_pro577(a_ano CHAR(4))
   RETURNING CHAR(50) as ramo,INTEGER as cnt_nuevas,DECIMAL(16,2) as suma_nueva,INTEGER as cnt_renovada,DECIMAL(16,2) as suma_renovada,INTEGER as cnt_caducadas,DECIMAL(16,2) as suma_caducadas,INTEGER as cnt_vigentes,DECIMAL(16,2) as suma_vigentes;
--------------------------------------------
---  APADEA
---  INFORMACION ESTADISTICA MENSUAL 
---  Armando Moreno M. 21/02/2002
---  Modificado: Amado Perez M. 12/03/2013 -- Se agrega el ramo 022 de equipo pesado a Ramos Tecnicos
---  Ref. Power Builder - d_sp_pro03b
--------------------------------------------
    DEFINE v_cod_ramo,v_cod_subramo,_cod_ramo,_cod_subramo  CHAR(3);
    DEFINE v_desc_ramo        CHAR(50);
    DEFINE v_desc_subramo     CHAR(50);
    DEFINE descr_cia	      CHAR(45);
    DEFINE unidades2          SMALLINT;
    DEFINE _no_poliza,_no_reclamo         CHAR(10);
    DEFINE v_cant_polizas,_cnt_reclamo          INTEGER;
    DEFINE v_prima_suscrita,v_prima_retenida,
           _prima_suscrita,_prima_retenida,v_suma_asegurada,
		   _total_pri_sus,v_incurrido_bruto,
           _salv_y_recup,_pago_y_ded,_var_reserva, _calculo		   DECIMAL(16,2);
    DEFINE _tipo,_nueva_renov              CHAR(01);
    DEFINE v_filtros          CHAR(255);
	DEFINE _mes1, _mes2,_mes,_ano2, _ano1,_orden, _meses   SMALLINT;
	DEFINE _fecha2, _fecha1     	      DATE;
	define _cod_tipoprod	  char(3);
	DEFINE _vigencia_inic, _vig_fin_vida, _vig_ini_end     DATE;
	define _no_endoso         char(5);
	define li_dia,li_mes,li_anio smallint;
	DEFINE _cnt_cerra,_cantidad            INTEGER;
	define _cod_origen        CHAR(3);
	DEFINE v_cant_polizas_ma, _cnt_prima_nva, _cnt_prima_ren, _cnt_prima_can, _cnt_pol_dif, _cantidad_aseg, v_cant_asegurados  INTEGER;
	DEFINE _orig SMALLINT;
	DEFINE _orden_sub smallint;
	DEFINE _periodo, _periodo1, _periodo2 CHAR(7);
	DEFINE _suma_asegurada DEC(16,2);
	DEFINE _fecha DATE;
	
	define _cant_pol_vig    integer;
	define _suma_pol_vig	dec(16,2);
	define _cant_pol_ren    integer;
	define _suma_pol_ren    dec(16,2);
	define _cant_pol_nue	integer;
	define _suma_pol_nue	dec(16,2);
	define _cant_pol_can	integer;
	define _suma_pol_can	dec(16,2);
	define _cant_pol_ven	integer;
	define _suma_pol_ven	dec(16,2);							  
 
	create temp table tmp_inuse(
	cod_ramo		char(3),
	cod_subramo     char(3),
	cant_pol_vig	integer		default 0,
	suma_pol_vig	dec(16,2)	default 0,
	cant_pol_ren	integer		default 0,
	suma_pol_ren	dec(16,2)	default 0,
	cant_pol_nue	integer		default 0,
	suma_pol_nue	dec(16,2)	default 0,
	cant_pol_can	integer		default 0,
	suma_pol_can	dec(16,2)	default 0
	) with no log;
	
LET v_cod_ramo       = NULL;
LET v_cod_subramo    = NULL;
LET v_desc_subramo   = NULL;
LET v_cant_polizas   = 0;
LET v_prima_suscrita = 0;
LET _prima_suscrita  = 0;
LET _tipo            = NULL;
let _salv_y_recup    = 0;
let _pago_y_ded      = 0;
let _var_reserva     = 0;
let _cnt_cerra       = 0;
LET v_cant_polizas_ma  = 0;
LET _cnt_prima_nva   = 0;
LET _cnt_prima_ren   = 0;
LET _cnt_prima_can   = 0;

SET ISOLATION TO DIRTY READ;

LET _periodo = a_ano || "-12";

let _periodo1 = a_ano || "-01";
let _periodo2 = a_ano || "-12";

let _fecha = MDY(12,31,a_ano);


--SET DEBUG FILE TO "sp_pro577.trc"; 
--trace on;


FOREACH
        SELECT cod_ramo,
			   cod_subramo,
			   sum(cnt_pol_nuevas),
			   sum(cnt_pol_ren),
			   sum(cnt_pol_can_cad)
         INTO  _cod_ramo,
			   _cod_subramo,
			   _cnt_prima_nva,
			   _cnt_prima_ren,
			   _cnt_prima_can
         FROM ramosubrh
		 WHERE periodo[1,4] = a_ano
	  group by cod_ramo,cod_subramo
	  ORDER BY cod_ramo,cod_subramo

        SELECT sum(cnt_polizas)
          INTO v_cant_polizas
          FROM ramosubrh
		 WHERE periodo = _periodo
		   AND cod_ramo = _cod_ramo
		   AND cod_subramo = _cod_subramo;

	IF _cod_ramo <> '017' THEN
		LET _cod_subramo = '001';
	END IF
		
	IF _cod_ramo = '020' OR _cod_ramo = '023' THEN
		LET _cod_ramo = '002';
		LET _cod_subramo = '001';
	END IF

	IF _cod_ramo = '021' THEN
		LET _cod_ramo = '001';
		LET _cod_subramo = '001';
	END IF

	IF _cod_ramo = "014" OR _cod_ramo = "013" OR _cod_ramo = "012" OR _cod_ramo = "011" OR _cod_ramo = "022" OR _cod_ramo = "007" THEN	--car y montaje
		LET _cod_ramo = '010';
		LET _cod_subramo = '001';
	END IF  
		   
	  insert into tmp_inuse (
			cod_ramo,
			cod_subramo,
			cant_pol_vig,
			cant_pol_ren,
			cant_pol_nue,
			cant_pol_can
	     ) values (
		    _cod_ramo,
			_cod_subramo,
			v_cant_polizas,
			_cnt_prima_nva,
			_cnt_prima_ren,
			_cnt_prima_can
			);

END FOREACH

-- Tabla Temporal temp_perfil

CALL sp_pro95(
'001',
'001',
_fecha,
'*',
'4;Ex') RETURNING v_filtros;

-- Tabla Temporal tmp_prod

CALL sp_pr26h(
'001',
'001',
_periodo1,
_periodo2,
'*',
'*',
'*',
'*',
'4;Ex',		--Reaseguro Asumido Excluido
'*',
'*',
'*'
) RETURNING v_filtros;


 foreach
	 select	   a.cod_ramo,
	           a.cod_subramo,
			   count(*),
			   sum(a.suma_asegurada)

	   into    _cod_ramo,
	           _cod_subramo,
			   _cant_pol_vig,
			   _suma_pol_vig

	    from   temp_perfil a
	    group  by cod_ramo, cod_subramo
		
		if _cod_ramo = '020' then
			let _suma_pol_vig = 5000 * _cant_pol_vig;
		end if

	IF _cod_ramo <> '017' THEN
		LET _cod_subramo = '001';
	END IF
		
	IF _cod_ramo = '020' OR _cod_ramo = '023' THEN
		LET _cod_ramo = '002';
		LET _cod_subramo = '001';
	END IF

	IF _cod_ramo = '021' THEN
		LET _cod_ramo = '001';
		LET _cod_subramo = '001';
	END IF

	IF _cod_ramo = "014" OR _cod_ramo = "013" OR _cod_ramo = "012" OR _cod_ramo = "011" OR _cod_ramo = "022" OR _cod_ramo = "007" THEN	--car y montaje
		LET _cod_ramo = '010';
		LET _cod_subramo = '001';
	END IF  
		
		insert into tmp_inuse(
			   cod_ramo,
			   cod_subramo,
			   suma_pol_vig
			   )
		values (_cod_ramo,
		       _cod_subramo,
		       _suma_pol_vig
		       );

end foreach	    

drop table temp_perfil;

-- Pólizas
foreach
  	 select p.cod_ramo,
  	        p.cod_subramo,
  	        sum(e.cnt_prima_ren),
  	        sum(e.cnt_prima_nva),
  	        sum(e.cnt_prima_can),			
 	        sum(e.total_suma_ren),
   	        sum(e.total_suma_nva),
  	        sum(e.total_suma_can)
      into	_cod_ramo,
	        _cod_subramo,
			_cant_pol_ren,
			_cant_pol_nue,
			_cant_pol_can,
			_suma_pol_ren,
			_suma_pol_nue,
			_suma_pol_can
	   from tmp_prod e, emipomae p
	  where e.no_poliza    = p.no_poliza
      group by p.cod_ramo, p.cod_subramo

		if _cod_ramo = '020' then
			let _suma_pol_ren = 5000 * _cant_pol_ren;
			let _suma_pol_nue = 5000 * _cant_pol_nue;
			let _suma_pol_can = -5000 * _cant_pol_can;
		end if

	IF _cod_ramo <> '017' THEN
		LET _cod_subramo = '001';
	END IF
		
	IF _cod_ramo = '020' OR _cod_ramo = '023' THEN
		LET _cod_ramo = '002';
		LET _cod_subramo = '001';
	END IF

	IF _cod_ramo = '021' THEN
		LET _cod_ramo = '001';
		LET _cod_subramo = '001';
	END IF

	IF _cod_ramo = "014" OR _cod_ramo = "013" OR _cod_ramo = "012" OR _cod_ramo = "011" OR _cod_ramo = "022" OR _cod_ramo = "007" THEN	--car y montaje
		LET _cod_ramo = '010';
		LET _cod_subramo = '001';
	END IF  

	insert into tmp_inuse(
			   cod_ramo,
			   cod_subramo,
			   suma_pol_ren,
			   suma_pol_nue,
			   suma_pol_can
			   )
		values (_cod_ramo,
		       _cod_subramo,
		       _suma_pol_ren,
			   _suma_pol_nue,
			   _suma_pol_can
		       );
end foreach

drop table tmp_prod;

foreach
    select 	cod_ramo,
			cod_subramo,
			sum(cant_pol_vig),
			sum(cant_pol_ren),
			sum(cant_pol_nue),
			sum(cant_pol_can),
		    sum(suma_pol_ren),
		    sum(suma_pol_nue),
		    sum(suma_pol_can),
		    sum(suma_pol_vig)
	   into _cod_ramo,
			_cod_subramo,
			v_cant_polizas,
			_cnt_prima_nva,
			_cnt_prima_ren,
			_cnt_prima_can,
            _suma_pol_ren,
			_suma_pol_nue,
			_suma_pol_can,
			_suma_pol_vig
	   from tmp_inuse
     group by cod_ramo, cod_subramo

       SELECT nombre
         INTO v_desc_ramo
         FROM prdramo
        WHERE cod_ramo = _cod_ramo;
	 
    IF _cod_ramo = "001" THEN
		  LET v_desc_ramo = "INCENDIO Y LINEAS ALIADAS";
    ELIF _cod_ramo = "009" THEN
		  LET v_desc_ramo = "TRANSPORTE DE CARGA";
    ELIF _cod_ramo = "010" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
    ELIF _cod_ramo = "011" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
    ELIF _cod_ramo = "012" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
    ELIF _cod_ramo = "013" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
    ELIF _cod_ramo = "014" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
   ELIF _cod_ramo = "022" THEN
		  LET v_desc_ramo = "RAMOS TECNICOS";
    ELIF _cod_ramo = "015" THEN
		  LET v_desc_ramo = "OTROS";
    ELIF _cod_ramo = "017" THEN
		  IF _cod_subramo = '001' THEN
			LET v_desc_ramo = "CASCO MARITIMO";
		  ELSE 
			LET v_desc_ramo = "CASCO AEREO";
		  END IF
    END IF


       RETURN   v_desc_ramo,  
	            _cnt_prima_nva,
				_suma_pol_nue,
                _cnt_prima_ren,				
				_suma_pol_ren,
               	_cnt_prima_can,
                _suma_pol_can,
				v_cant_polizas,
				_suma_pol_vig
				 WITH RESUME;
end foreach
drop table tmp_inuse;
END PROCEDURE;