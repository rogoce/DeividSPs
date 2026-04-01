-- Procedimiento para traer la ayuda saldo agentes
--
-- Creado    : 26/06/2003 - Autor: Lic. Amado Perez Mendoza 
-- Modificado: 26/06/2003 - Autor: Lic. Amado Perez Mendoza
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE call01;

CREATE PROCEDURE "informix".call01(a_cobrador CHAR(3))
	   RETURNING CHAR(5),  
	             CHAR(100),
	             CHAR(50), 
	             CHAR(10), 
	             CHAR(20),
	             smallint;

   DEFINE _cobra_poliza	 	CHAR(1);
   DEFINE v_cod_agente  	CHAR(5); 
   DEFINE v_agente      	CHAR(100);
   DEFINE v_cobrador    	CHAR(50);
   define _nombre_agente	char(100);
   define _no_poliza char(10);
   define _cnt          smallint;
   define a_cod_cliente,_cod_cliente char(10);
   define a_no_documento char(20);
   define _li_return,_estatus_p smallint;
   	
   LET a_no_documento = '';
   LET v_cobrador     = '';
   LET v_cod_agente   = ''; 
   LET v_agente       = '';

   SET ISOLATION TO DIRTY READ;
	   
SELECT nombre 
  INTO v_cobrador
  FROM cobcobra
 WHERE cod_cobrador = a_cobrador;

foreach

	select cod_agente
	  into v_cod_agente
	  from agtagent
	 where cod_cobrador = a_cobrador

  foreach

   SELECT c.no_documento
	 into a_no_documento
     FROM emipomae c, emipoagt e
    WHERE c.no_poliza = e.no_poliza
	  and c.actualizado = 1
      and e.cod_agente = '00797' --v_cod_agente
      and c.cobra_poliza = 'C'
    group by c.no_documento

	let	_no_poliza = sp_sis21(a_no_documento);

	select count(*)
	  into _cnt
	  from emipomae
	 where no_poliza    = _no_poliza
	   and actualizado  = 1
	   and cobra_poliza = "C";

	 if _cnt > 0 then

		   {	select cod_pagador
			  into a_cod_cliente
			  from emipomae
			 where actualizado = 1
			   and no_poliza   = _no_poliza;

			 select	cod_cliente
			   into	_cod_cliente
			   from	cascliente
			  where	cod_cliente = a_cod_cliente;

			 if _cod_cliente is null then  --pagador no esta en el call center

				 let _li_return = sp_cas027(a_cod_cliente); --insertar cascliente y caspoliza

			 else

				if a_no_documento <> "*" then	--inserta poliza a un pagador existente
					let _li_return = sp_cas027(a_cod_cliente, a_no_documento); --insertar cascliente y caspoliza
				end if

			 end if	}
	select estatus_poliza
	  into _estatus_p
	  from emipomae
	 where no_poliza    = _no_poliza;


	   SELECT nombre
		 INTO v_agente
		 FROM agtagent
		WHERE cod_agente = v_cod_agente;

	   RETURN v_cod_agente,  
			  v_agente,      
			  v_cobrador,
			  _no_poliza,
			  a_no_documento,
			  _estatus_p with resume;

	 else
		continue foreach;
	 end if

{	   SELECT nombre
		 INTO v_agente
		 FROM agtagent
		WHERE cod_agente = v_cod_agente;

	   RETURN v_cod_agente,  
			  v_agente,      
			  v_cobrador,
			  _no_poliza,
			  a_no_documento with resume; }
		   
   END FOREACH
end foreach

{foreach

	select poliza
	  into a_no_documento
	  from a

	let _no_poliza = sp_sis21(a_no_documento);

	select cod_pagador
	  into a_cod_cliente
	  from emipomae
	 where actualizado = 1
	   and no_poliza   = _no_poliza;

	 select	cod_cliente
	   into	_cod_cliente
	   from	cascliente
	  where	cod_cliente = a_cod_cliente;

	 if _cod_cliente is null then  --pagador no esta en el call center

		 let _li_return = sp_cas027(a_cod_cliente); --insertar cascliente y caspoliza

	 else

		if a_no_documento <> "*" then	--inserta poliza a un pagador existente
			let _li_return = sp_cas027(a_cod_cliente, a_no_documento); --insertar cascliente y caspoliza
		end if

	 end if

end foreach	}
               
END PROCEDURE
