-- Procedimieto que genera la los datos de la fecha de expiracion de tarjeta de credito
--
-- Creado    : 09/07/2014 - Autor: Angel Tello
--
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob868;

create procedure "informix".sp_cob868(a_no_tarjeta	char(20))
			returning   char(100),
						char(20),
						char(255),
						char(100),
						char(7),
						char(100),
						char(10);

define _ano				char(4);
define _mes				char(2);
define _cod_pagador		char(10);
define _fecha_char		char(30);
define _e_mail			char(50);
define _nombre_aseg		char(100);
define _periodo_ex		char(7);
define _nombre_cli		char(100);
define _cod_cliente		char(10);
define _no_poliza       char(10);
define _no_documento    char(20);
define _no_documento1    char(20);
define _len_documento   smallint;
define _len_n_documento	smallint;
define _no_doc_ac		varchar(255);
define _direcion		char(100);
define _tarjeta_cre	    char(20);
define _cont			smallint;
define _cod_banco		char(3);
define _nombre_ban		char(100);
define _usuario			char(10);
define _tip_tajeta      smallint;

set isolation to dirty read;



 SELECT fecha_exp,
		cod_banco,
        tipo_tarjeta
   INTO _periodo_ex,
		_cod_banco,
        _tip_tajeta
   FROM cobtahab
  WHERE no_tarjeta = a_no_tarjeta;

IF _tip_tajeta = 4 THEN
    LET _tarjeta_cre =  a_no_tarjeta[1,4] ||'-XXXXXX-'|| a_no_tarjeta[13,18];
ELSE
    LET _tarjeta_cre =  a_no_tarjeta[1,4] ||'-XXXX-XXXX-'|| a_no_tarjeta[16,20];
END IF


  SELECT nombre
    INTO _nombre_ban
	FROM chqbanco
   WHERE cod_banco = _cod_banco;

  FOREACH
	 SELECT no_documento
	   INTO _no_documento
	   FROM cobtacre
	  WHERE no_tarjeta  = a_no_tarjeta

	  EXIT FOREACH;
	END FOREACH

	LET _no_poliza = sp_sis21(_no_documento);

	 SELECT cod_contratante
	   INTO _cod_cliente
	   FROM	emipomae
	  WHERE	no_poliza = _no_poliza
	    AND actualizado  = 1;

  SELECT nombre,
		 direccion_1
    INTO _nombre_cli,
		 _direcion
    FROM cliclien
   WHERE cod_cliente = _cod_cliente;



	SELECT COUNT(*)
	  INTO _cont
	  FROM cobtacre
	 WHERE no_tarjeta  = a_no_tarjeta;

	 LET _no_doc_ac = '';

   FOREACH
	 SELECT no_documento
	   INTO _no_documento1
	   FROM cobtacre
	  WHERE no_tarjeta  = a_no_tarjeta

	  IF _cont = 1 THEN
		LET _no_doc_ac  = _no_documento1;
	  ELSE
		LET  _no_doc_ac =  trim(_no_documento1) || ','|| trim(_no_doc_ac) ;
	  END IF
	END FOREACH

	LET _no_doc_ac = TRIM(_no_doc_ac);

	FOREACH
		SELECT usuario
		  INTO _usuario
		  FROM parfirca
		 WHERE cod_fircarta = '027'

		 EXIT FOREACH;
	END FOREACH

    RETURN _nombre_cli,
		   _tarjeta_cre,
		   _no_doc_ac,
		   _direcion,
		   _periodo_ex,
		   _nombre_ban,
		   _usuario;

end procedure
