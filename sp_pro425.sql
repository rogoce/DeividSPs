   DROP procedure sp_pro425;
   CREATE procedure "informix".sp_pro425(a_periodo CHAR(7))
   RETURNING SMALLINT AS NRO, 
             VARCHAR(15) AS PROVINCIA,
			 DEC(16,2) AS PRIMA_PERSONA,
			 DEC(16,2) AS PRIMA_GENERALES,
			 DEC(16,2) AS PRIMA_FIANZA,
			 DEC(16,2) AS INCURRIDO_PERSONA,
			 DEC(16,2) AS INCURRIDO_GENERALES,
			 DEC(16,2) AS INCURRIDO_FIANZA;
--------------------------------------------
---  APADEA
---  DISTIBUCION GEOGRAFICA
---
---  Amado Perez M. 02/02/2007
---  Modificado 12/03/2013 se agrega el ramo 022 de equipo pesado a Ramos Tecnicos
---  Ref. Power Builder
--------------------------------------------

	DEFINE _prima_pma		  dec(16,2);
	DEFINE _prima_col		  dec(16,2);
	DEFINE _prima_chi		  dec(16,2);
	DEFINE _prima_her		  dec(16,2);
	DEFINE _prima_ver		  dec(16,2);
	DEFINE _prima_pmo		  dec(16,2);
	DEFINE _prima_otro		  dec(16,2);
	DEFINE _prima_ext     	  dec(16,2);
	DEFINE _incu_pma		  dec(16,2);
	DEFINE _incu_col		  dec(16,2);
	DEFINE _incu_chi		  dec(16,2);
	DEFINE _incu_her		  dec(16,2);
	DEFINE _incu_ver		  dec(16,2);
	DEFINE _incu_pmo		  dec(16,2);
	DEFINE _incu_otro		  dec(16,2);
	DEFINE _incu_ext		  dec(16,2);
	define _error_desc		char(255); 
    define _error_isam		integer; 
    define _error			integer;	
	DEFINE _orden             smallint;
	DEFINE _nro    				smallint;
    DEFINE _provincia     	  varchar(15);
    DEFINE _prima_personas   	dec(16,2);
    DEFINE _prima_generales		dec(16,2);
    DEFINE _prima_fianzas 		dec(16,2);
    DEFINE _incu_personas		dec(16,2);
    DEFINE _incu_generales		dec(16,2);
    DEFINE _incu_fianzas		dec(16,2);
	
create temp TABLE tmp_dist_geo (
   nro         			smallint,
   provincia   			varchar(15),
   prima_personas    	dec(16,2),
   prima_generales   	dec(16,2),
   prima_fianzas     	dec(16,2), 
   incu_personas    	dec(16,2),
   incu_generales   	dec(16,2),
   incu_fianzas     	dec(16,2))  with no log;

 insert into tmp_dist_geo values (1, 'BOCAS DEL TORO', 0, 0, 0, 0, 0, 0);  
 insert into tmp_dist_geo values (2, 'COCLE', 0, 0, 0, 0, 0, 0);  
 insert into tmp_dist_geo values (3, 'COLON', 0, 0, 0, 0, 0, 0);  
 insert into tmp_dist_geo values (4, 'CHIRIQUI', 0, 0, 0, 0, 0, 0);  
 insert into tmp_dist_geo values (5, 'DARIEN', 0, 0, 0, 0, 0, 0);  
 insert into tmp_dist_geo values (6, 'HERRERA', 0, 0, 0, 0, 0, 0);  
 insert into tmp_dist_geo values (7, 'LOS SANTOS', 0, 0, 0, 0, 0, 0);  
 insert into tmp_dist_geo values (8, 'PANAMA', 0, 0, 0, 0, 0, 0);  
 insert into tmp_dist_geo values (9, 'VERAGUAS', 0, 0, 0, 0, 0, 0);  
 insert into tmp_dist_geo values (10, 'GUNA YALA', 0, 0, 0, 0, 0, 0);  
 insert into tmp_dist_geo values (11, 'EMBERA WONAN', 0, 0, 0, 0, 0, 0);  
 insert into tmp_dist_geo values (12, 'NGABE-BUGLE', 0, 0, 0, 0, 0, 0);  
 insert into tmp_dist_geo values (13, 'PANAMA OESTE', 0, 0, 0, 0, 0, 0);  

let _error = 0; 
let _error_isam = 0;
let _error_desc = ' ';


SET ISOLATION TO DIRTY READ;
begin

on exception set _error,_error_isam,_error_desc
	return _error, _error_desc,0,0,0,0,0,0;
end exception


	LET _prima_pma = 0;
	LET _prima_col = 0;
	LET _prima_chi = 0;
	LET _prima_her = 0;
	LET _prima_ver = 0;
	LET _prima_pmo = 0;
	LET _prima_otro = 0;
	LET _prima_ext = 0;
	LET _incu_pma = 0;
	LET _incu_col = 0;
	LET _incu_chi = 0;
	LET _incu_her = 0;
	LET _incu_ver = 0;
	LET _incu_pmo = 0;
	LET _incu_otro = 0;
	LET _incu_ext = 0;

  FOREACH
	  SELECT orden,
	         SUM(prima_pma),
			 SUM(prima_col),
			 SUM(prima_chi),
			 SUM(prima_pmo),
			 SUM(prima_ver),
			 SUM(prima_her),
			 SUM(incu_pma),
			 SUM(incu_col),
			 SUM(incu_chi),
			 SUM(incu_pmo),
			 SUM(incu_ver),
			 SUM(incu_her)
	    INTO _orden,
		     _prima_pma,
             _prima_col,
 			 _prima_chi,
			 _prima_pmo,
			 _prima_ver,
			 _prima_her,
			 _incu_pma,
			 _incu_col,
			 _incu_chi,
			 _incu_pmo,
			 _incu_ver,
			 _incu_her
        FROM ssrpestm5
	   WHERE periodo = a_periodo
	  GROUP BY orden
	  ORDER BY orden

      IF _orden = 1 THEN
		UPDATE tmp_dist_geo
		   SET prima_personas = _prima_pma, 
		       incu_personas  = _incu_pma
         WHERE nro = 8;			   

		UPDATE tmp_dist_geo
		   SET prima_personas = _prima_col, 
		       incu_personas  = _incu_col
         WHERE nro = 3;			   

		UPDATE tmp_dist_geo
		   SET prima_personas = _prima_chi, 
		       incu_personas  = _incu_chi
         WHERE nro = 4;			   

		UPDATE tmp_dist_geo
		   SET prima_personas = _prima_pmo, 
		       incu_personas  = _incu_pmo
         WHERE nro = 13;			   

		UPDATE tmp_dist_geo
		   SET prima_personas = _prima_ver, 
		       incu_personas  = _incu_ver
         WHERE nro = 9;			   

		UPDATE tmp_dist_geo
		   SET prima_personas = _prima_her, 
		       incu_personas  = _incu_her
         WHERE nro = 6;			   
	  ELIF _orden = 2 THEN	 
 		UPDATE tmp_dist_geo
		   SET prima_generales = _prima_pma, 
		       incu_generales  = _incu_pma
         WHERE nro = 8;			   

		UPDATE tmp_dist_geo
		   SET prima_generales = _prima_col, 
		       incu_generales  = _incu_col
         WHERE nro = 3;			   

		UPDATE tmp_dist_geo
		   SET prima_generales = _prima_chi, 
		       incu_generales  = _incu_chi
         WHERE nro = 4;			   

		UPDATE tmp_dist_geo
		   SET prima_generales = _prima_pmo, 
		       incu_generales  = _incu_pmo
         WHERE nro = 13;			   

		UPDATE tmp_dist_geo
		   SET prima_generales = _prima_ver, 
		       incu_generales  = _incu_ver
         WHERE nro = 9;			   

		UPDATE tmp_dist_geo
		   SET prima_generales = _prima_her, 
		       incu_generales  = _incu_her
         WHERE nro = 6;			   
     ELSE
		UPDATE tmp_dist_geo
		   SET prima_fianzas = _prima_pma, 
		       incu_fianzas  = _incu_pma
         WHERE nro = 8;			   

		UPDATE tmp_dist_geo
		   SET prima_fianzas = _prima_col, 
		       incu_fianzas  = _incu_col
         WHERE nro = 3;			   

		UPDATE tmp_dist_geo
		   SET prima_fianzas = _prima_chi, 
		       incu_fianzas  = _incu_chi
         WHERE nro = 4;			   

		UPDATE tmp_dist_geo
		   SET prima_fianzas = _prima_pmo, 
		       incu_fianzas  = _incu_pmo
         WHERE nro = 13;			   

		UPDATE tmp_dist_geo
		   SET prima_fianzas = _prima_ver, 
		       incu_fianzas  = _incu_ver
         WHERE nro = 9;			   

		UPDATE tmp_dist_geo
		   SET prima_fianzas = _prima_her, 
		       incu_fianzas  = _incu_her
         WHERE nro = 6;			   
     END IF      

END FOREACH

--SET DEBUG FILE TO "sp_pro178.trc";
--trace on;

---RECLAMOS
FOREACH
 SELECT nro,
        provincia,
        prima_personas,
        prima_generales,
        prima_fianzas, 
        incu_personas,
        incu_generales,
        incu_fianzas
   INTO _nro,		
        _provincia,
        _prima_personas,
        _prima_generales,
        _prima_fianzas, 
        _incu_personas,
        _incu_generales,
        _incu_fianzas
   FROM tmp_dist_geo
  ORDER BY nro
  
 RETURN _nro,
        _provincia,
        _prima_personas,
        _prima_generales,
        _prima_fianzas, 
        _incu_personas,
        _incu_generales,
        _incu_fianzas WITH RESUME;
         
END FOREACH

  
DROP TABLE if exists tmp_dist_geo;

end
--commit work;
END PROCEDURE 
                                                               
