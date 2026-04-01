-- Pasar Registros de Endosos de un numero de poliza a otro

DROP PROCEDURE sp_par46;

CREATE PROCEDURE "informix".sp_par46(
_no_poliza			CHAR(10),
_no_endoso			CHAR(5),
_no_poliza_nuevo	CHAR(10)
) returning integer, char(100); 

define _error	integer;

begin

ON EXCEPTION SET _error 
	rollback work;
 	return _error, "Error al Realizar la Actualizacion";         
END EXCEPTION           

begin work;

DELETE FROM emifafac WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM emifacon WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endcamre WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endcamrf WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;

DELETE FROM endcobde WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endcobre WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endedcob WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endcuend WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endmotra WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endmoaut WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endedde2 WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endedacr WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endunide WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endunire WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endeduni WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endedimp WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endedrec WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endeddes WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endasien WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endmoage WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endmoase WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endcamco WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endedde1 WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;
DELETE FROM endedmae WHERE no_poliza = _no_poliza_nuevo AND no_endoso = _no_endoso;

select * 
  from endedmae
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso
  into temp tmp_endoso;

update tmp_endoso
   set no_poliza = _no_poliza_nuevo;

insert into endedmae
select *
  from tmp_endoso;

update endedde1
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endcamco
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endmoase
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endmoage
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endasien
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endeddes
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endedrec
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endedimp
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

-- Unidades

drop table tmp_endoso;

select * 
  from endeduni
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso
  into temp tmp_endoso;

update tmp_endoso
   set no_poliza = _no_poliza_nuevo;

insert into endeduni
select *
  from tmp_endoso;

update endunire
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endunide
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endedacr
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endedde2
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endmoaut
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endmotra
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endcuend
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

-- Coberturas

drop table tmp_endoso;

select * 
  from endedcob
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso
  into temp tmp_endoso;

update tmp_endoso
   set no_poliza = _no_poliza_nuevo;

insert into endedcob
select *
  from tmp_endoso;

update endcobre
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endcobde
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endcamrf
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update endcamre
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

update emifacon
   set no_poliza = _no_poliza_nuevo
 where no_poliza = _no_poliza
   and no_endoso = _no_endoso;

DELETE FROM emifafac WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM emifacon WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcamre WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcamrf WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;

DELETE FROM endcobde WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcobre WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedcob WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcuend WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmotra WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoaut WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedde2 WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedacr WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endunide WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endunire WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endeduni WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedimp WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedrec WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endeddes WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endasien WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoage WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endmoase WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endcamco WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedde1 WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;
DELETE FROM endedmae WHERE no_poliza = _no_poliza AND no_endoso = _no_endoso;

commit work;

return 0, "Actualizacion Exitosa ...";

end 

END PROCEDURE 
