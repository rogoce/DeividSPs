-- sp_pro409b Corrige emipoagt y endmoage cuando el corredror es directo en el traspaso de cartera
-- Creado    : 07/08/2018- Autor: Henry Giron
-- SIS v.2.0 - DEIVID, S.A.
--execute procedure sp_pro409b('00035',today)
DROP procedure sp_pro409b;
CREATE procedure "informix".sp_pro409b(a_cod_agente_new	char(5),a_fecha_efectiva date default current)
RETURNING char(15) as cod_agente,
		  char(20) as no_documento,
		  char(10) as no_poliza,
		  char(5) as no_endoso,
		  char(3) as cod_ramo,
		  char(3) as cod_subramo,
		  decimal(5,2) as porc_comis_agt,
		  decimal(5,2) as porc_comis_real;
		  
DEFINE _no_endoso		        char(5);		  
DEFINE 	_porc_comis_agt,_porc_comis_real    decimal(5,2);
DEFINE  _cod_ramo, _cod_subramo char(3);
DEFINE 	_no_documento         char(20);
DEFINE  _cod_agente           char(15);
DEFINE 	_no_poliza            char(10);
define _tipo_agente		      char(1);
	
   SET ISOLATION TO DIRTY READ;
   
   let _cod_agente = a_cod_agente_new; --'02587';  

FOREACH WITH HOLD
    select b.no_documento, a.no_poliza, a.no_endoso
	  into _no_documento,_no_poliza, _no_endoso
     from endedmae a,deivid_tmp:traspasos_corredor b
    where b.cod_agente_new = _cod_agente  -- '02587'
      and b.procesado in( 1,2)
      and a.no_documento = b.no_documento
      and a.cod_endomov = '031' -- traspaso
      and a.fecha_emision = a_fecha_efectiva --'06/08/2018'	  
		  
		select porc_comis_agt
		  into _porc_comis_agt
		  from emipoagt
		 where no_poliza = _no_poliza
		   and cod_agente = _cod_agente;

		if _porc_comis_agt is null then
			let _porc_comis_agt = 0;
		end if
		
		select tipo_agente
		  into _tipo_agente
		  from agtagent
		 where cod_agente = _cod_agente;	

		if _porc_comis_agt = 0 or _tipo_agente = "O" then		  
		
			select cod_ramo,
				   cod_subramo
			  into _cod_ramo,
				   _cod_subramo
			  from emipomae
			 where no_poliza = _no_poliza;
			
	
			  LET _porc_comis_real = 0;

			  LET _porc_comis_real = sp_pro305(_cod_agente, _cod_ramo, _cod_subramo);		
		
			update endmoage
		       set porc_comis_agt = _porc_comis_real
		     where no_poliza      = _no_poliza
		       and no_endoso      = _no_endoso
			   and cod_agente     = _cod_agente;  
			   
            update emipoagt
		       set porc_comis_agt = _porc_comis_real
		     where no_poliza = _no_poliza
		       and cod_agente = _cod_agente;  
		   
			RETURN _cod_agente,
					_no_documento,
					_no_poliza,
					_no_endoso,
					_cod_ramo,
					_cod_subramo,
					_porc_comis_agt,
					_porc_comis_real
					WITH RESUME;		   

		end if	  	
   END FOREACH

END PROCEDURE