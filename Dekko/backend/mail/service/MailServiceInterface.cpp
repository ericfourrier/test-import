/*
 * This file was generated by qdbusxml2cpp version 0.8
 * Command line was: qdbusxml2cpp /home/dan/dekko/Dekko/backend/mail/service/dbus/service_worker.xml -N -p MailServiceInterface -c MailServiceInterface
 *
 * qdbusxml2cpp is Copyright (C) 2016 The Qt Company Ltd.
 *
 * This is an auto-generated file.
 * This file may have been hand-edited. Look for HAND-EDIT comments
 * before re-generating it.
 */

#include "MailServiceInterface.h"

/*
 * Implementation of interface class MailServiceInterface
 */

MailServiceInterface::MailServiceInterface(const QString &service, const QString &path, const QDBusConnection &connection, QObject *parent)
    : QDBusAbstractInterface(service, path, staticInterfaceName(), connection, parent)
{
}

MailServiceInterface::~MailServiceInterface()
{
}

