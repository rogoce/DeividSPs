--Polizas forma de pago ancon agrupadas por corredor, solicitado por Maque
--18/03/2025

DROP procedure sp_jean17v5;
CREATE procedure sp_jean17v5(a_periodo char(7),a_renov char(1))
RETURNING char(5),char(50),char(20),date,date,char(3),char(50),char(3),char(50),char(30),char(10);


DEFINE _no_poliza,_tel1,_cod_contratante CHAR(10);
DEFINE _no_documento        			CHAR(20);
define _cod_ramo,_cod_subramo    		char(3);
define _n_agente,_n_ramo,_n_subramo     char(50);
define _email							char(30);
define _cod_agente   					char(5);
define _suma_asegurada,_prima_ret    	dec(16,2);
define _vig_fin,_vig_ini                date;
define _estatus                         smallint;

foreach
	select no_documento,cod_ramo,cod_subramo,vigencia_inic,vigencia_fin,cod_agente,no_poliza
	  into _no_documento,_cod_ramo,_cod_subramo,_vig_ini,_vig_fin,_cod_agente,_no_poliza
	 from emipoliza
    where cod_formapag = '006'
 group by cod_agente,no_documento,cod_ramo,cod_subramo,vigencia_inic,vigencia_fin,no_poliza
 order by cod_agente

select cod_contratante,
       estatus_poliza
  into _cod_contratante,
       _estatus
  from emipomae
 where no_poliza = _no_poliza;
 
if _estatus <> 1 then
	continue foreach;
end if

select e_mail,
       telefono1
  into _email,
       _tel1
  from cliclien
 where cod_cliente = _cod_contratante;
 
 select nombre into _n_agente from agtagent
 where cod_agente = _cod_agente;

 select nombre into _n_ramo from prdramo
 where cod_ramo = _cod_ramo;

 select nombre into _n_subramo from prdsubra
 where cod_ramo = _cod_ramo
   and cod_subramo  = _cod_subramo;


return _cod_agente,_n_agente,_no_documento,_vig_ini,_vig_fin,_cod_ramo,_n_ramo,_cod_subramo,_n_subramo,_email,_tel1 with resume;

end foreach


END PROCEDURE;
