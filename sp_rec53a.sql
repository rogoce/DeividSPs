-- Codigo de cliente en los recuperos (Actualizacion) 
-- Creado    : 06/03/2006 - Autor: Armando Moreno

--DROP PROCEDURE sp_rec53a;

CREATE PROCEDURE "informix".sp_rec53a()
{ RETURNING	CHAR(18), 	   -- Reclamo
			CHAR(10), 	   -- cod_cliente
			CHAR(50),	   -- nombre tercero
			CHAR(10), 	   -- remesa
			CHAR(10); 	   -- cliente tercero}

DEFINE v_numrecla          CHAR(18);
DEFINE _doc_remesa         CHAR(18);
DEFINE v_nombre_cliente    CHAR(50);
DEFINE v_no_documento      CHAR(20);
define _cod_cliente        CHAR(10);
define _no_remesa          CHAR(10);
define _cod_cte			   CHAR(10);

SET ISOLATION TO DIRTY READ;

foreach

 SELECT numrecla,
        cod_cliente
   INTO	v_numrecla,
        _cod_cte
   FROM recrecup
  order by 1

  if _cod_cte is not null then
	SELECT nombre
	  INTO v_nombre_cliente
	  FROM cliclien
	 WHERE cod_cliente = _cod_cte;
	   
    update recrecup
	   set nombre_cliente = v_nombre_cliente
	 where cod_cliente    = _cod_cte;
  end if

 {let v_nombre_cliente = "";
 let _no_remesa       = "";
 let _cod_cliente     = "";

  foreach

  	SELECT cod_recibi_de,
	       no_remesa,
		   doc_remesa
	  INTO _cod_cliente,
	       _no_remesa,
		   _doc_remesa
	  FROM cobredet
	 WHERE doc_remesa  = v_numrecla
	   and actualizado = 1
	   and tipo_mov    = "R"
	 order by 3

	exit foreach;
  end foreach

  if _no_remesa is null then
	let v_nombre_cliente = "";
	let _no_remesa       = "";
	let _cod_cliente     = "";
  else

	let v_nombre_cliente = "";
	   
	if _cod_cliente is null or _cod_cliente = "" then
		let v_nombre_cliente = "";
		let _no_remesa       = "";
		let _cod_cliente     = "";
	else
	    {update recrecup
		   set cod_cliente = _cod_cliente
		 where numrecla  = v_numrecla;}

  {		SELECT nombre
		  INTO v_nombre_cliente
		  FROM cliclien
		 WHERE cod_cliente = _cod_cliente;
    end if

  end if


  	RETURN	v_numrecla,
		    _cod_cliente,
			v_nombre_cliente,
			_no_remesa,
			_cod_cte
			WITH RESUME;}
end foreach
END PROCEDURE;

