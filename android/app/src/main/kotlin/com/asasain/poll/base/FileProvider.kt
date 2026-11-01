package com.asasain.poll.base

// Custom FileProvider — clone com.ninja.engine.base.FileProvider
// Extend AndroidX FileProvider untuk handle file sharing antar proses sandbox
class FileProvider : androidx.core.content.FileProvider()
