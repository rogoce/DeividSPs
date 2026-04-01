--***********************************************************************************
-- Procedimiento que genera data para Mini convencion
--***********************************************************************************
-- Creado    : 15/02/2011 - Autor: Armando Moreno
-- Modificado: 15/02/2011 - Autor: Armando Moreno
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_che86bk;
CREATE PROCEDURE sp_che86bk(a_compania CHAR(3),a_sucursal CHAR(3),a_periodo1 char(7),a_periodo2 char(7))
RETURNING CHAR(5),
		  CHAR(100),			
		  DECIMAL(16,2), 			
		  DECIMAL(16,2), 		
		  integer,				
		  integer,
		  DECIMAL(16,2), 			
		  DECIMAL(16,2),
		  char(1);

define _cod_coasegur	char(3);				   
define _error           smallint;				   
define _filtros			char(255);				   
define _no_documento    char(20); 				   
define _no_poliza       char(10);
define _cod_ramo        char(3);
define _cod_subramo     char(3);  
define _monto           DEC(16,2);
define _monto_p         DEC(16,2);
define _monto_s         DEC(16,2);
define _fecha           DATE;     
define _prima           DEC(16,2);
define _renglon         integer;
define _porc_coaseguro	dec(16,4);
define _cod_tipoprod    CHAR(3);  
define _tipo_prod       smallint; 
define _cod_tiporamo    CHAR(3);  
define _tipo_ramo       smallint; 
define _nueva_renov     char(1);
define _cod_agencia		char(3);
define _cnt             integer;
define _cod_agente   	char(5);
define _prima_sus_pag   DEC(16,2);
define _nombre          CHAR(100); 
define _pri_sus_pag     dec(16,2);
define _prima_suscrita  DEC(16,2);
define _fecha_pago      date;
define _pri_pag_nue		DEC(16,2);
define _pri_pag_ren		DEC(16,2);
define _nuevas			integer;
define _renovadas		integer;
define _pri_sus_nue		DEC(16,2);
define _pri_sus_ren		DEC(16,2);
define _tipo_agente     char(1);
define _porc_partic_agt DEC(5,2);
define _pri_pag_nue_t	DEC(16,2);
define _pri_pag_ren_t	DEC(16,2);
define _nuevas_t	   	integer;
define _renovadas_t  	integer;
define _pri_sus_nue_t	DEC(16,2);
define _pri_sus_ren_t	DEC(16,2);
define _tipo_persona    char(1);

--SET DEBUG FILE TO "sp_che86bk.trc";

let _prima_sus_pag  = 0;
let _cnt            = 0;
let _error          = 0;

select par_ase_lider
  into _cod_coasegur
  from parparam
 where cod_compania = a_compania;	 

create temp table tmp_concurso(
no_documento	char(20),
pri_pag_nue		dec(16,2) 	default 0,
pri_pag_ren		dec(16,2) 	default 0,
nueva_cnt       integer,
renov_cnt       integer,
prima_sus_nue  	dec(16,2) 	default 0,
prima_sus_ren  	dec(16,2) 	default 0,
cod_agente      char(5),
PRIMARY KEY (no_documento)
) with no log;	 

create temp table tmp_con(
pri_pag_nue		dec(16,2) 	default 0,
pri_pag_ren		dec(16,2) 	default 0,
nueva_cnt       integer,
renov_cnt       integer,
prima_sus_nue  	dec(16,2) 	default 0,
prima_sus_ren  	dec(16,2) 	default 0,
cod_agente      char(5),
no_documento   	char(20)
) with no log; 	 

SET ISOLATION TO DIRTY READ;

-------------------------------------------------------
INSERT INTO tmp_concurso(no_documento,pri_pag_nue,pri_pag_ren,nueva_cnt,renov_cnt)
SELECT DISTINCT no_documento,0,0,0,0
  FROM emipomae
 WHERE actualizado = 1
   AND periodo >= a_periodo1
   AND periodo <= a_periodo2
   AND cod_grupo <> "00000";


FOREACH WITH HOLD

	   SELECT no_documento
		 INTO _no_documento
		 FROM tmp_concurso
	 ORDER BY no_documento

		let _no_poliza = sp_sis21(_no_documento);

		SELECT cod_ramo,
		       cod_subramo,
			   cod_tipoprod,
			   nueva_renov,
			   prima_suscrita
	      INTO _cod_ramo,
		       _cod_subramo,
			   _cod_tipoprod,
			   _nueva_renov,
			   _prima_suscrita
		  FROM emipomae
	     WHERE no_poliza = _no_poliza;

		 SELECT tipo_produccion
		   INTO _tipo_prod
		   FROM emitipro
		  WHERE cod_tipoprod = _cod_tipoprod;

		-- Excluir Reaseguro Asumido y Coas. Minoritario

	   	{ if _tipo_prod = 3 or _tipo_prod = 4 or _tipo_prod = 2 THEN   -- Excluir Coaseguros y Reaseguro Asumido
		   continue foreach;
		 end if

	   	 select count(*)
		   into _cnt
		   from emifafac
		  where no_poliza = _no_poliza;

		 if _cnt > 0 then		-- Excluir Facultativos
			 continue foreach;
		 end if

	    select count(*)
		  into _cnt
		  from emipouni
		 where no_poliza = _no_poliza;

		if _cnt > 1 then		--se excluye Colectivos y Flotas
			continue foreach;
		end if }


		if _nueva_renov = "N" then

			update tmp_concurso
			   set nueva_cnt     = 1,
			       prima_sus_nue = _prima_suscrita
	 		 where no_documento  = _no_documento;
		else
		   {	update tmp_concurso
			   set renov_cnt     = 1,
				   prima_sus_ren = _prima_suscrita
	 		 where no_documento  = _no_documento;}

			continue foreach;
		end if

		--**********************
		-- Prima Pagada       --  						
		--**********************

		foreach
		 select prima_neta,
				fecha,
				renglon,
				no_poliza
		   into _monto,
				_fecha_pago,
				_renglon,
				_no_poliza
		   from cobredet
		  where doc_remesa  = _no_documento
		    and periodo     >= a_periodo1
		    and periodo     <= a_periodo2
			and actualizado = 1
			and tipo_mov    in ("P","N")			
		  
			select cod_tipoprod
			  into _cod_tipoprod
			  from emipomae
			 where no_poliza = _no_poliza;

			if _cod_tipoprod = "004" then
				continue foreach;
			end if

			if _cod_tipoprod = "001" then

				select porc_partic_coas
				  into _porc_coaseguro
				  from emicoama
				 where no_poliza    = _no_poliza
				   and cod_coasegur = _cod_coasegur;

				if _porc_coaseguro is null then
					let _porc_coaseguro = 0.00;
				end if

				let _monto = _monto * (_porc_coaseguro / 100);
			end if

			if _nueva_renov = "N" then
				update tmp_concurso
				   set pri_pag_nue  = pri_pag_nue + _monto
				 where no_documento = _no_documento;
			else
			   {	update tmp_concurso
				   set pri_pag_ren  = pri_pag_ren + _monto
				 where no_documento = _no_documento;}
			   continue foreach;

			end if
		end foreach


END FOREACH

foreach
	 select pri_pag_nue,
			pri_pag_ren,
			nueva_cnt,
			renov_cnt,
			prima_sus_nue,
			prima_sus_ren,
			no_documento   
	   into _pri_pag_nue,
	        _pri_pag_ren,
	        _nuevas,
	        _renovadas,
	        _pri_sus_nue,
	        _pri_sus_ren,
	        _no_documento
       from tmp_concurso	
	  Order by no_documento

   	    let _no_poliza = sp_sis21(_no_documento);

	 foreach
		   SELECT cod_agente,porc_partic_agt
			 INTO _cod_agente,_porc_partic_agt
			 FROM emipoagt
			WHERE no_poliza = _no_poliza

			  Let _pri_pag_nue_t = _pri_pag_nue * (_porc_partic_agt / 100);
			  Let _pri_pag_ren_t = _pri_pag_ren * (_porc_partic_agt / 100);
			  Let _nuevas_t	     = _nuevas;
			  Let _renovadas_t   = _renovadas;
			  Let _pri_sus_nue_t = _pri_sus_nue * (_porc_partic_agt / 100);
			  Let _pri_sus_ren_t = _pri_sus_ren * (_porc_partic_agt / 100);

			INSERT INTO tmp_con(
				   pri_pag_nue,			
 				   pri_pag_ren,			
 				   nueva_cnt,     	  
				   renov_cnt,     	  
				   prima_sus_nue, 	 	
				   prima_sus_ren, 	 	
				   cod_agente,
				   no_documento     	 
				   )	
				   VALUES(	
				   _pri_pag_nue_t,	 
				   _pri_pag_ren_t,	 	  
				   _nuevas_t,	   	   
				   _renovadas_t,  	 
				   _pri_sus_nue_t,	 
				   _pri_sus_ren_t,	  				
				   _cod_agente,
				   _no_documento
				   );	

	 end foreach
end foreach


foreach
	 select sum(pri_pag_nue),
			sum(pri_pag_ren),
			sum(nueva_cnt),
			sum(renov_cnt),
			sum(prima_sus_nue),
			sum(prima_sus_ren),
			cod_agente   
	   into _pri_pag_nue,
	        _pri_pag_ren,
	        _nuevas,
	        _renovadas,
	        _pri_sus_nue,
	        _pri_sus_ren,
	        _cod_agente
       from tmp_con
	  group by cod_agente
	  Order by cod_agente

	  select nombre,
	         tipo_agente,
			 tipo_persona
	    into _nombre,
		     _tipo_agente,
			 _tipo_persona
		from agtagent
	   where cod_agente = _cod_agente;

	  if _tipo_agente = "O" then
		continue foreach;
	  end if

	  RETURN _cod_agente,
		     _nombre,
		     _pri_pag_nue,
		     _pri_pag_ren,
		     _nuevas,
		     _renovadas,
		     _pri_sus_nue,
		     _pri_sus_ren,
		     _tipo_persona 
		     WITH RESUME;

end foreach		
											  
drop table tmp_concurso;
drop table tmp_con;

END PROCEDURE;	  	 